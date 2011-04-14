# Cookbook Name:: db_mysql
# Recipe:: setup_mysql
#
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

# == Configure system for MySQL
#

# Stop MySQL
service "mysql" do
  supports :status => true, :restart => true, :reload => true
  action :stop
end


# moves mysql default db to storage location, removes ib_logfiles for re-config of innodb_log_file_size
ruby_block "clean innodb logfiles" do
  block do
    require 'fileutils'
    remove_files = ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ib_logfile*')) + ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ibdata*'))
    FileUtils.rm_rf(remove_files)
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
include_recipe "db_mysql::setup_my_cnf"

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

