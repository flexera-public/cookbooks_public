#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

service "apache2" do
  action :nothing
end

# == Setup PHP Apache vhost on port 80
#
php_port = "80"

# disable default vhost
apache_site "000-default" do
  enable false
end

template "#{node[:apache][:dir]}/ports.conf" do
  cookbook "apache2"
  source "ports.conf.erb"
  variables :apache_listen_ports => php_port
  notifies :restart, resources(:service => "apache2")
#  notifies :restart, resources(:service => "apache2"), :immediately
end

# == Configure apache vhost for PHP
#
web_app "#{node[:web_apache][:application_name]}.frontend" do
  template "apache.conf.erb"
  docroot node[:web_apache][:docroot]
  vhost_port php_port
  server_name node[:web_apache][:server_name]
end

rs_utils_marker :end
