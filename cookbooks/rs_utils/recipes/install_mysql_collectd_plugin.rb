#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Load the mysql plugin in the main config file
rs_utils_enable_collectd_plugin "mysql"
#node[:rs_utils][:plugin_list] += " mysql" unless node[:rs_utils][:plugin_list] =~ /mysql/

include_recipe "rs_utils::setup_monitoring"

log "Installing MySQL collectd plugin"

package "collectd-mysql" do
  only_if {  node[:platform] =~ /redhat|centos/ }
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
rs_utils_monitor_process "mysqld"
template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

rs_utils_marker :end
