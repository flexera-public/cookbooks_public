# Cookbook Name:: app_passenger
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
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
#

rs_utils_marker :begin

service "apache2" do
  action :nothing
end

# Checking for user FQDN
if (node[:web_apache][:server_name] == "")
  log("Your FQDN is not set. Now it will be changed to :www.mydomain.com Please set DMS name manually, when you start this instance."){ level :warn }
  node[:web_apache][:server_name] = "www.mydomain.com"
end

# Installing passenger module
  log"INFO: Installing passenger"
gem_package "passenger" do
  gem_binary node[:app_passenger][:gem_bin]
  not_if do (File.exists?("/opt/ruby-enterprise/bin/passenger-install-apache2-module")) end
end

bash "install_apache_passenger_module" do
  code <<-EOH
    /opt/ruby-enterprise/bin/passenger-install-apache2-module --auto
  EOH
end

# Generation of new apache ports.conf, based on user prefs
template "#{node[:app_passenger][:install_dir_option]}/ports.conf" do
  source "ports.conf.erb"
end

# Generation of new vhost config, based on user prefs
  log"INFO: Generating new apache vhost"
web_app "http-#{node[:app_passenger][:port]}-#{node[:web_apache][:server_name]}.vhost" do
  template "basic_vhost.erb"
  docroot node[:app_passenger][:public_root]
  vhost_port node[:app_passenger][:port]
  server_name node[:web_apache][:server_name]
  rails_env node[:app_passenger][:environment]
  notifies :restart, resources(:service => "apache2"), :immediately
end

rs_utils_logrotate_app "rails" do
  cookbook "app_passenger"
  template "logrotate_rails.erb"
  path ["/var/log/rails/*log" ]
  frequency "daily"
  rotate 7
  create "660 apache apache"
end

rs_utils_marker :end









