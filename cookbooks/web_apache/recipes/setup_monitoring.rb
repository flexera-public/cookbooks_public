# Cookbook Name:: web_apache
# Recipe:: setup_monitoring
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

# add the collectd exec plugin to the set of collectd plugins if it isn't already there
rs_utils_enable_collectd_plugin 'exec'

# rebuild the collectd configuration file if necessary
include_recipe "rs_utils::setup_monitoring"

service "httpd" do
  action :nothing
end

arch = node[:kernel][:machine]
arch = "i386" if arch == "i686"

if node[:platform] == 'centos'

  TMP_FILE = "/tmp/collectd-apache.rpm"

  remote_file TMP_FILE do
    source "collectd-apache-4.10.0-4.el5.#{arch}.rpm"
  end

  package TMP_FILE do
    source TMP_FILE
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

  if node[:web_apache][:mpm] == "prefork"
    node[:rs_utils][:process_list] += " httpd"
  else
    node[:rs_utils][:process_list] += " httpd.worker"
  end
 
  # update the collectd config file for the processes collectd plugin and restart collectd if necessary
  template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
    backup false
    cookbook "rs_utils"
    source "processes.conf.erb"
    notifies :restart, resources(:service => "collectd")
  end
else
  Chef::Log.info "WARNING: attempting to install collectd-apache on unsupported platform #{node[:platform]}, continuing.."
end
