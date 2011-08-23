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
  @db = init(new_resource)
  @db.set_privileges
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
