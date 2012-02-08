# Cookbook Name:: repo
# Provider:: repo_git
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :stop do
  bash "Starting apache" do
    code <<-EOH
     /etc/init.d/#{node[:app_passenger][:apache][:demon]} stop
    EOH
  end
end

action :start do
  bash "Starting apache" do
    code <<-EOH
     /etc/init.d/#{node[:app_passenger][:apache][:demon]} start
    EOH
  end
end

action :restart do
  action_stop
  action_start
end


action :install do

  #Installing some apache development headers required for rubyEE
  log "Packages which will be installed #{node[:app_passenger][:packages_install]}"
  node[:app_passenger][:packages_install].each do |p|
    package p
  end

  #Saving project name variables
  ENV['RAILS_APP'] = node[:web_apache][:application_name]

  bash "save global vars" do
    code <<-EOH
      echo $RAILS_APP >> /tmp/appname
    EOH
  end

end

action :setup_vhost do

service "apache2" do
  action :nothing
end

#Removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  backup false
  only_if do File.exists?("/etc/httpd/conf.d/ssl.conf")  end
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


end
