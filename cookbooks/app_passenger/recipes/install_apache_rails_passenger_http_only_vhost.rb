# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
#gem_package "passenger" do
#  gem_binary node[:app_passenger][:gem_bin]
#  not_if do (File.exists?("/opt/ruby-enterprise/bin/passenger-install-apache2-module")) end
#end

bash "Install apache passenger gem" do
  code <<-EOH
/opt/ruby-enterprise/bin/gem install passenger -q --no-rdoc --no-ri
  EOH
  not_if do (File.exists?("/opt/ruby-enterprise/bin/passenger-install-apache2-module")) end
end



bash "install_apache_passenger_module" do
  code <<-EOH
    /opt/ruby-enterprise/bin/passenger-install-apache2-module --auto
  EOH
  not_if "test -e #{node[:app_passenger][:ruby_gem_base_dir].chomp}/gems/passenger*/ext/apache2/mod_passenger.so"
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









