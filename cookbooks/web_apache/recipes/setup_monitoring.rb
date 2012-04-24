#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# add the collectd exec plugin to the set of collectd plugins if it isn't already there
rs_utils_enable_collectd_plugin 'exec'

# rebuild the collectd configuration file if necessary
include_recipe "rs_utils::setup_monitoring"

service "httpd" do
  case node[:platform]
  when 'ubuntu'
    service_name 'apache2'
  end
  action :nothing
end

if node[:platform] =~ /redhat|centos/

  TMP_FILE = "/tmp/collectd-apache.rpm"

  remote_file TMP_FILE do
    source "collectd-apache-4.10.0-4.el5.#{node[:kernel][:machine]}.rpm"
  end

  package TMP_FILE do
    source TMP_FILE
  end

  if node[:web_apache][:mpm] == "prefork"
    rs_utils_monitor_process "httpd"
  else
    rs_utils_monitor_process "httpd.worker"
  end
 
elsif node[:platform] == 'ubuntu'

  rs_utils_monitor_process 'apache2'

else
  Chef::Log.info "WARNING: attempting to install collectd-apache on unsupported platform #{node[:platform]}, continuing.."
end

# add Apache configuration for the status URL and restart Apache if necessary
template File.join(node[:apache][:dir], 'conf.d', 'status.conf') do
  backup false
  source "apache_status.conf.erb"
  notifies :restart, resources(:service => "httpd")
end

# create the collectd library plugins directory if necessary
directory ::File.join(node[:rs_utils][:collectd_lib], "plugins") do
  action :create
  recursive true
end

# install the apache_ps collectd script into the collectd library plugins directory
remote_file(::File.join(node[:rs_utils][:collectd_lib], "plugins", 'apache_ps')) do
  source "apache_ps"
  mode "0755"
end

# add a collectd config file for the Apache collectd plugin and restart collectd if necessary
template File.join(node[:rs_utils][:collectd_plugin_dir], 'apache.conf') do
  backup false
  source "apache_collectd_plugin.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

# add a collectd config file for the apache_ps script with the exec plugin and restart collectd if necessary
template File.join(node[:rs_utils][:collectd_plugin_dir], 'apache_ps.conf') do
  backup false
  source "apache_collectd_exec.erb"
  notifies :restart, resources(:service => "collectd")
end

# update the collectd config file for the processes collectd plugin and restart collectd if necessary
template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
  backup false
  cookbook "rs_utils"
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

rs_utils_marker :end
