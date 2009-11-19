# Cookbook Name:: app_php
# Recipe:: install_php
#
# Copyright (c) 2009 RightScale Inc
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

include_recipe "web_apache"

[ @node[:php][:package_dependencies] | @node[:php][:modules_list] ].flatten.each do |p|
  package p
end

@node[:php][:module_dependencies].each do |mod|
  apache_module mod
end

# grab application source from remote repository
include_recipe "app_php::do_update_code"

php_port =  @node[:php][:application_port]

# if port 80, disable default vhost
if php_port == "80" 
  apache_site "000-default" do
    enable false
  end
end

ports = @node[:apache][:listen_ports].include?(php_port) \
    ? @node[:apache][:listen_ports] \
    : [@node[:apache][:listen_ports], php_port].flatten

template "#{@node[:apache][:dir]}/ports.conf" do
  cookbook "apache2"
  source "ports.conf.erb"
  variables :apache_listen_ports => ports
  notifies :restart, resources(:service => "apache2")
end

web_app @node[:php][:application_name] do
  template "php_web_app.conf.erb"
  docroot @node[:php][:code][:destination]
  vhost_port @node[:php][:application_port]
  server_name @node[:php][:server_name]
end

directory File.join(@node[:php][:code][:destination], "config") do
  recursive true 
end

template File.join(@node[:php][:code][:destination], "config", "db.php") do
  source "config_db.php.erb"
  variables({
   :db_handle => "#{@node[:php][:db_dns_name]}:#{@node[:db_mysql][:socket]}"
  })
end

bash "chown_home" do
  code <<-EOH
    chown -R #{@node[:php][:app_user]}:#{@node[:php][:app_user]} #{@node[:php][:code][:destination]}
  EOH
end
