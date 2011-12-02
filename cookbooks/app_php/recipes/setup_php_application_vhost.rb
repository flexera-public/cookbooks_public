#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

service "apache2" do
  action :nothing
end

# disable default vhost
apache_site "000-default" do
  enable false
end

php_port = node[:app][:port].to_s
node[:apache][:listen_ports] << php_port unless node[:apache][:listen_ports].include?(php_port)

template "#{node[:apache][:dir]}/ports.conf" do
  cookbook "apache2"
  source "ports.conf.erb"
  variables :apache_listen_ports => node[:apache][:listen_ports]
  notifies :restart, resources(:service => "apache2")
end

# == Configure apache vhost for PHP
#
#web_app node[:php][:application_name] do
web_app node[:web_apache][:application_name] do
  template "app_server.erb"
  docroot node[:web_apache][:docroot]
  vhost_port node[:app][:port]
  server_name node[:web_apache][:server_name]
  cookbook "web_apache"
  notifies :restart, resources(:service => "apache2"), :immediately
end

rs_utils_marker :end
