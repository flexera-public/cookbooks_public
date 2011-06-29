# Cookbook Name:: db_mysql
# Recipe:: server
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

include_recipe "db_mysql::install_client"

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
#  service_name value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "mysqld"}, "default" => "mysql")  
  supports :status => true, :restart => true, :reload => true
  action :stop
end

# Create MySQL server system tables
touchfile = "~/.mysql_installed"
execute "/usr/bin/mysql_install_db ; touch #{touchfile}" do
  creates touchfile
end
