# Cookbook Name:: rs_utils
# Recipe:: install_mysql_collectd_plugin
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

# Load the mysql plugin in the main config file
rs_utils_enable_collectd_plugin "mysql"
#node[:rs_utils][:plugin_list] += " mysql" unless node[:rs_utils][:plugin_list] =~ /mysql/

include_recipe "rs_utils::setup_monitoring"

log "Installing MySQL collectd plugin"

package "collectd-mysql" do
  only_if {  node[:platform] == "centos" }
end

remote_file "#{node[:rs_utils][:collectd_plugin_dir]}/mysql.conf" do
  backup false
  source "collectd.mysql.conf"
  notifies :restart, resources(:service => "collectd")
end

# When using the dot notation the following error is thrown
#
# You tried to set a nested key, where the parent is not a hash-like object: rs_utils/process_list/process_list
#
# The only related issue I could find was for Chef 0.9.8 - http://tickets.opscode.com/browse/CHEF-1680
node[:rs_utils][:process_list] += " mysqld"
template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end
