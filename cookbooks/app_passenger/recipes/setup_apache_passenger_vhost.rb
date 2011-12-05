#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

service "apache2" do
  action :nothing
end

# Generation of new apache ports.conf, based on user prefs
template "#{node[:app_passenger][:apache][:install_dir]}/ports.conf" do
  source "ports.conf.erb"
end

#unlinking default apache vhost if it exists
link "#{node[:app_passenger][:apache][:install_dir]}/sites-enabled/000-default" do
  action :delete
  only_if "test -L #{node[:app_passenger][:apache][:install_dir].chomp}/sites-enabled/000-default"
end


# Generation of new vhost config, based on user prefs
log"INFO: Generating new apache vhost"
web_app "http-#{node[:app_passenger][:apache][:port]}-#{node[:web_apache][:server_name]}.vhost" do
  template "basic_vhost.erb"
  docroot node[:app_passenger][:public_root]
  vhost_port node[:app_passenger][:apache][:port]
  server_name node[:web_apache][:server_name]
  rails_env node[:app_passenger][:project][:environment]
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









