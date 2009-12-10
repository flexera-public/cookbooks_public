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


include_recipe "mysql::client"

log "EC2 Instance type detected: #{@node[:db_mysql][:server_usage]}-#{@node[:ec2][:instance_type]}" if @node[:ec2] == "true"

# preseeding is only required for ubuntu and debian
case node[:platform]
when "debian","ubuntu"

  directory "/var/cache/local/preseeding" do
    owner "root"
    group "root"
    mode "755"
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

package "mysql-server" do
  action :install
end

# install other packages we require
@node[:db_mysql][:packages_install].each do |p| 
  package p 
end unless @node[:db_mysql][:packages_install] == ""

# uninstall other packages we don't
@node[:db_mysql][:packages_uninstall].each do |p| 
   package p do
     action :remove
   end
end unless @node[:db_mysql][:packages_uninstall] == ""

service "mysql" do
  service_name value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "mysqld"}, "default" => "mysql")  
  supports :status => true, :restart => true, :reload => true
  action :enable
end

# Create it so mysql can use it if configured
file "/var/log/mysqlslow.log" do
  owner "mysql"
  group "mysql"
end

# Initialize the binlog dir
binlog = `dirname #{@node[:db_mysql][:log_bin]}`.strip
directory binlog do
  owner "mysql"
  group "mysql"
  recursive true
end

# Disable the "check_for_crashed_tables" for ubuntu
case node[:platform]
when "debian","ubuntu"
  execute "sed -i 's/^.*check_for_crashed_tables.*/  #check_for_crashed_tables;/g' /etc/mysql/debian-start"
end

# Drop in best practice replacement for mysqld startup.  Timeouts enabled.
template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/init.d/mysqld"}, "default" => "/etc/init.d/mysql") do
  source "init-mysql.erb"
  mode "0755"  
end

template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :server_id => "#{Time.now.to_i}"
  )
  notifies :restart, resources(:service => "mysql"), :immediately
end

# safe_mysqld is bogusly runaway here, we should only need to kill it once after the install happens.
ruby_block "fix buggy safe_mysqld" do
  block do
    bug = `pgrep mysqld_safe`.chomp.to_i
    unless bug == 0
      Chef::Log.info("found buggy mysqld_save, killing")
      Process.kill(15, bug) unless bug == 0
    end
  end
end

if (! FileTest.directory?(node[:db_mysql][:datadir_relocate]))
  
  service "mysql" do
    action :stop
  end
  
  execute "install-mysql" do
    command "mv #{node[:db_mysql][:datadir]} #{node[:db_mysql][:datadir_relocate]}"
  end
  
  link node[:db_mysql][:datadir] do
   to node[:db_mysql][:datadir_relocate]
  end
  
  directory @node[:db_mysql][:datadir_relocate] do
    owner "mysql"
    group "mysql"
    mode "0775"
    recursive true
  end
  
  service "mysql" do
    action :start
  end
end
 
## Fix Privileges 4.0+
execute "/usr/bin/mysql_fix_privilege_tables"


