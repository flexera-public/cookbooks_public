# Cookbook Name:: db_mysql
# Recipe:: server
#
# Copyright (c) 2009 RightScale Inc
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

include_recipe "db_mysql::client"

# Log resource submitted to opscode. http://tickets.opscode.com/browse/CHEF-923
log "EC2 Instance type detected: #{@node[:db_mysql][:server_usage]}-#{@node[:ec2][:instance_type]}" if @node[:ec2] == "true"

# preseeding is only required for ubuntu and debian
case node[:platform]
when "debian","ubuntu"

  directory "/var/cache/local/preseeding" do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end
  
  execute "preseed mysql-server" do
    command "debconf-set-selections /var/cache/local/preseeding/mysql-server.seed"
    action :nothing
  end

  template "/var/cache/local/preseeding/mysql-server.seed" do
    source "mysql-server.seed.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, resources(:execute => "preseed mysql-server"), :immediately
  end
  
  remote_file "/etc/mysql/debian.cnf" do
    source "debian.cnf"
  end
end

# THIS INSTALLS PLATFORM EQUIVALENT OF the mysql-server package; see attributes. 
# ALSO install other packages we require.
@node[:db_mysql][:packages_install].each do |p| 
  package p 
end unless @node[:db_mysql][:packages_install] == ""

# uninstall other packages we don't
@node[:db_mysql][:packages_uninstall].each do |p| 
   package p do
     action :remove
   end
end unless @node[:db_mysql][:packages_uninstall] == ""

# Drop in best practice replacement for mysqld startup.  Timeouts enabled.
template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/init.d/mysqld"}, "default" => "/etc/init.d/mysql") do
  source "init-mysql.erb"
  mode "0755"  
end

# Setup my.cnf 
include_recipe "db_mysql::setup_my_cnf"

# Initialize the binlog dir
binlog = ::File.dirname(@node[:db_mysql][:log_bin])
directory binlog do
  owner "mysql"
  group "mysql"
  recursive true
end

# Create it so mysql can use it if configured
file "/var/log/mysqlslow.log" do
  owner "mysql"
  group "mysql"
end

service "mysql" do
  service_name value_for_platform([ "centos", "redhat", "suse", "fedora" ] => {"default" => "mysqld"}, "default" => "mysql")
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart mysql"
    stop_command "stop mysql"
    start_command "start mysql"
  end
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# Disable the "check_for_crashed_tables" for ubuntu
# And setup Debian maintenance user
case node[:platform]
when "debian","ubuntu"
  execute "sed -i 's/^.*check_for_crashed_tables.*/  #check_for_crashed_tables;/g' /etc/mysql/debian-start"
  execute "sed -i 's/user.*/user = #{@node[:db_mysql][:admin_user]}/g' /etc/mysql/debian.cnf"
  execute "sed -i 's/password.*/password = #{@node[:db_mysql][:admin_user]}/g' /etc/mysql/debian.cnf"
end

# bugfix: mysqd_safe high cpu usage
# https://bugs.launchpad.net/ubuntu/+source/mysql-dfsg-5.0/+bug/105457
service "mysql" do
  only_if do
    right_platform = node[:platform] == "ubuntu" && 
                    (node[:platform_version] == "8.04" || 
                     node[:platform_version] == "8.10")

    right_platform && node[:db_mysql][:kill_bug_mysqld_safe]
  end

  action :stop
end

ruby_block "fix buggy mysqld_safe" do
  only_if do
    right_platform = node[:platform] == "ubuntu" && 
                    (node[:platform_version] == "8.04" || 
                     node[:platform_version] == "8.10")

    right_platform && node[:db_mysql][:kill_bug_mysqld_safe]
  end
  block do
    Chef::Log.info("Found buggy mysqld_safe on first boot..")
    output = ""
    status = Chef::Mixin::Command.popen4("pgrep mysqld_safe") do |pid, stdin, stdout, stderr|
      stdout.each do |line|
        output << line.strip
      end
    end
    bug = output.to_i
    unless bug == 0
      Chef::Log.info("Buggy mysql_safe PID: #{bug}, killing..")
      Process.kill(15, bug) unless bug == 0
    end
    node[:db_mysql][:kill_bug_mysqld_safe] = false
  end
end

service "mysql" do
  only_if do true end # http://tickets.opscode.com/browse/CHEF-894
  not_if do ::File.symlink?(node[:db_mysql][:datadir]) end
  action :stop
end

# moves mysql default db to storage location, removes ib_logfiles for re-config of innodb_log_file_size
ruby_block "clean innodb logfiles, relocate default datafiles to storage drive, symlink storage to default datadir" do
  not_if do ::File.symlink?(node[:db_mysql][:datadir]) end
  block do
    require 'fileutils'
    remove_files = ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ib_logfile*')) + ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ibdata*'))
    Chef::Log.info("Prep for innodb config changes on pristine install, removing files: #{remove_files.join(',')} ")
    FileUtils.rm_rf(remove_files)
    Chef::Log.info("Relocating default mysql datafiles to #{node[:db_mysql][:datadir_relocate]}")
    FileUtils.cp_r(node[:db_mysql][:datadir], node[:db_mysql][:datadir_relocate])
    FileUtils.rm_rf(node[:db_mysql][:datadir])
    File.symlink(node[:db_mysql][:datadir_relocate], node[:db_mysql][:datadir])
  end
end

ruby_block "chown mysql datadir" do
  block do
    FileUtils.chown_R("mysql", "mysql", node[:db_mysql][:datadir_relocate])
  end
end

service "mysql" do
  not_if do false end # http://tickets.opscode.com/browse/CHEF-894
  Chef::Log.info "Attempting to start mysql service"
  action :start
end
 
## Fix Privileges 4.0+
execute "/usr/bin/mysql_fix_privilege_tables"
