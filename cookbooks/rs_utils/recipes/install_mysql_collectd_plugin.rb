# Cookbook Name:: rs_utils
# Recipe:: install_mysql_collectd_plugin
#
# Copyright (c) 2010 RightScale Inc
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

log "Installing MySQL collectd plugin"

package "collectd-mysql" do
  only_if {  node.platform == "centos" }
end

remote_file "#{node.rs_utils.collectd_plugin_dir}/mysql.conf" do
  source "collectd.mysql.conf"
  notifies :restart, resources(:service => "collectd")
end

node.rs_utils.process_list += " mysqld"
template File.join(node.rs_utils.collectd_plugin_dir, 'processes.conf') do
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end
