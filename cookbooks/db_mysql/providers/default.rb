# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

include RightScale::Database::MySQL::Helper

action :stop do
  @db = init(new_resource)
  @db.stop
end

action :start do
  @db = init(new_resource)
  @db.start
end

action :status do
  @db = init(new_resource)
  status = @db.status
  log "Database Status:\n#{status}"
end

action :lock do
  @db = init(new_resource)
  @db.unlock
end

action :unlock do
  @db = init(new_resource)
  @db.unlock
end

action :move_data_dir do
  @db = init(new_resource)
  @db.move_datadir
end

action :reset do
  @db = init(new_resource)
  @db.reset
end

action :pre_restore_check do
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

action :post_restore_cleanup do
  @db = init(new_resource)
  @db.symlink_datadir("/var/lib/mysql", node[:db][:data_dir])
  # TODO: used for replication
  # @db.post_restore_sanity_check
  @db.post_restore_cleanup
end

action :pre_backup_check do
  @db = init(new_resource)
  @db.pre_backup_check
  # TODO: used for replication
  # @db.write_mysql_backup_info
end

action :post_backup_cleanup do
  @db = init(new_resource)
  @db.clean_backup_info
end

action :set_privileges do
  priv = new_resource.privilege
  priv_username = new_resource.privilege_username
  priv_password = new_resource.privilege_password
  priv_database = new_resource.privilege_database
  db_mysql_set_privileges "setup db privileges" do
    preset priv
    username priv_username
    password priv_password
    database priv_database
  end
end

action :install_client do

  # == Install MySQL 5.1 package(s)
  if node[:platform] == "centos"

    # Install MySQL GPG Key (http://download.oracle.com/docs/cd/E17952_01/refman-5.5-en/checking-gpg-signature.html)
    gpgkey = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", "mysql_pubkey.asc")
    `rpm --import #{gpgkey}`

    # Packages from rightscale-software repository for MySQL 5.1
    packages = ["MySQL-shared-compat", "MySQL-devel-community", "MySQL-client-community" ]
    Chef::Log.info("Packages to install: #{packages.join(",")}")
    packages.each do |p|
      r = package p do
        action :nothing
      end
      r.run_action(:install)
    end

  else

    # Install development library in compile phase
    p = package "mysql-dev" do
      package_name value_for_platform(
        "ubuntu" => {
          "8.04" => "libmysqlclient15-dev",
          "8.10" => "libmysqlclient15-dev",
          "9.04" => "libmysqlclient15-dev"
        },
        "default" => 'libmysqlclient-dev'
      )
      action :nothing
    end
    p.run_action(:install)

    # install client in converge phase
    package "mysql-client" do
      package_name value_for_platform(
        [ "centos", "redhat", "suse" ] => { "default" => "mysql" },
        "default" => "mysql-client"
      )
      action :install
    end

  end


  # == Install MySQL client gem
  #
  # Also installs in compile phase
  #
  r = execute "install mysql gem" do
    command "/opt/rightscale/sandbox/bin/gem install mysql --no-rdoc --no-ri -v 2.7 -- --build-flags --with-mysql-config"
  end
  r.run_action(:run)

  Gem.clear_paths
  log "Gem reload forced with Gem.clear_paths"
end

action :install_server do

  # MySQL server depends on MySQL client
  action_install_client

  # == Install MySQL 5.1 and other packages
  #
  node[:db_mysql][:packages_install].each do |p|
    package p
  end unless node[:db_mysql][:packages_install] == ""

  # Uninstall other packages we don't
  node[:db_mysql][:packages_uninstall].each do |p|
     package p do
       action :remove
     end
  end unless node[:db_mysql][:packages_uninstall] == ""

  service "mysql" do
    #service_name value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "mysqld"}, "default" => "mysql")
    supports :status => true, :restart => true, :reload => true
    action :stop
  end

  # Create MySQL server system tables
  touchfile = ::File.expand_path "~/.mysql_installed"
  execute "/usr/bin/mysql_install_db ; touch #{touchfile}" do
    creates touchfile
  end

  # == Configure system for MySQL
  #

  # Stop MySQL
  service "mysql" do
    supports :status => true, :restart => true, :reload => true
    action :stop
  end


  # moves mysql default db to storage location, removes ib_logfiles for re-config of innodb_log_file_size
  touchfile = ::File.expand_path "~/.mysql_dbmoved"
  ruby_block "clean innodb logfiles" do
    not_if { ::File.exists?(touchfile) }
    block do
      require 'fileutils'
      remove_files = ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ib_logfile*')) + ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ibdata*'))
      FileUtils.rm_rf(remove_files)
      ::File.open(touchfile,'a'){}
    end
  end

  # Initialize the binlog dir
  binlog = ::File.dirname(node[:db_mysql][:log_bin])
  directory binlog do
    owner "mysql"
    group "mysql"
    recursive true
  end

  # Create the tmp directory
  directory "/mnt/mysqltmp" do
    owner "mysql"
    group "mysql"
    mode 0770
    recursive true
  end

  # Create it so mysql can use it if configured
  file "/var/log/mysqlslow.log" do
    owner "mysql"
    group "mysql"
  end

  # Setup my.cnf
  template_source = "my.cnf.erb"

  template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
    source template_source
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => node[:db_mysql][:server_id]
    )
    cookbook 'db_mysql'
  end

  # == Setup MySQL user limits
  #
  # Set the mysql and root users max open files to a really large number.
  # 1/3 of the overall system file max should be large enough.  The percentage can be
  # adjusted if necessary.
  #
  mysql_file_ulimit = `sysctl -n fs.file-max`.to_i/33

  template "/etc/security/limits.d/mysql.limits.conf" do
    source "mysql.limits.conf.erb"
    variables({
      :ulimit => mysql_file_ulimit
    })
    cookbook 'db_mysql'
  end

  # Change root's limitations for THIS shell.  The entry in the limits.d will be
  # used for future logins.
  # The setting needs to be in place before mysql is started.
  #
  execute "ulimit -n #{mysql_file_ulimit}"


  # == Drop in best practice replacement for mysqld startup.
  #
  # Timeouts enabled.
  #
  template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/init.d/mysql"}, "default" => "/etc/init.d/mysql") do
    source "init-mysql.erb"
    mode "0755"
    cookbook 'db_mysql'
  end

  ## == Setup log rotation
  ##
  #rs_utils_logrotate_app "mysql-server" do
  #  template "mysql-server.logrotate.erb"
  #  cookbook "db_mysql"
  #  path ["/var/log/mysql*.log", "/var/log/mysql*.err" ]
  #  frequency "daily"
  #  rotate 7
  #  create "640 mysql adm"
  #end

  # == Start MySQL
  #
  service "mysql" do
    supports :status => true, :restart => true, :reload => true
    action :start
  end

end

action :setup_monitoring do
  service "collectd" do
    action :nothing
  end

  arch = node[:kernel][:machine]
  arch = "i386" if arch == "i686"

  if node[:platform] == 'centos'

    TMP_FILE = "/tmp/collectd.rpm"

    remote_file TMP_FILE do
      source "collectd-mysql-4.10.0-4.el5.#{arch}.rpm"
      cookbook 'db_mysql'
    end

    package TMP_FILE do
      source TMP_FILE
    end

    template ::File.join(node[:rs_utils][:collectd_plugin_dir], 'mysql.conf') do
      backup false
      source "mysql_collectd_plugin.conf.erb"
      notifies :restart, resources(:service => "collectd")
      cookbook 'db_mysql'
    end

  else

    log "WARNING: attempting to install collectd-mysql on unsupported platform #{node[:platform]}, continuing.." do
      level :warn
    end

  end
end
