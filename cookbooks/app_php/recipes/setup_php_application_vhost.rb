# Cookbook Name:: app_php
# Recipe:: setup_php_application_vhost
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

rs_utils_marker :begin

service "apache2" do
  action :nothing
end

# disable default vhost
apache_site "000-default" do
  enable false
end

node[:apache][:listen_ports] << node[:app][:port] unless node[:apache][:listen_ports].include?(node[:app][:port])

template "#{node[:apache][:dir]}/ports.conf" do
  cookbook "apache2"
  source "ports.conf.erb"
  variables :apache_listen_ports => node[:apache][:listen_ports]
  notifies :restart, resources(:service => "apache2"), :immediately
end

# == Configure apache vhost for PHP
#
#web_app node[:php][:application_name] do
web_app node[:web_apache][:application_name] do
  template "app_server.erb"
  docroot node[:web_apache][:docroot]
  vhost_port node[:app][:port]
  server_name node[:php][:server_name]
  cookbook "web_apache"
  notifies :restart, resources(:service => "apache2"), :immediately
end

rs_utils_marker :end
