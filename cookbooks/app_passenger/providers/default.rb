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


end

action :setup_vhost do

#service "apache2" do
#  action :nothing
#end

#Removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
  file "/etc/httpd/conf.d/ssl.conf" do
    action :delete
    backup false
    only_if do ::File.exists?("/etc/httpd/conf.d/ssl.conf")  end
  end


# Generation of new apache ports.conf, based on user prefs
  template "#{node[:app_passenger][:apache][:install_dir]}/ports.conf" do
    source "ports.conf.erb"
    cookbook 'app_passenger'
  end

#unlinking default apache vhost if it exists
  link "#{node[:app_passenger][:apache][:install_dir]}/sites-enabled/000-default" do
    action :delete
    only_if "test -L #{node[:app_passenger][:apache][:install_dir].chomp}/sites-enabled/000-default"
  end

#application_root = new_resource.app_root
#application_port = new_resource.app_port

# Generation of new vhost config, based on user prefs
  log"INFO: Generating new apache vhost"
  web_app "http-#{node[:app_passenger][:apache][:port]}-#{node[:web_apache][:server_name]}.vhost" do
    template "basic_vhost.erb"
    docroot node[:app_passenger][:public_root]
    # docroot application_root
    vhost_port node[:app_passenger][:apache][:port]
    # vhost_port application_port
    server_name node[:web_apache][:server_name]
    rails_env node[:app_passenger][:project][:environment]
    cookbook 'app_passenger'
  #  notifies :restart, resources(:service => "apache2"), :immediately
  end


end

action :setup_db_connection do

  if node[:app_passenger][:project][:db][:adapter]=="mysql"

    #packages required for mysql gem
    node[:app_passenger][:mysql_packages_install]= ["mysql", "mysql-devel","mysqlclient15", "mysqlclient15-devel"]

    case node[:platform]

      when "redhat","redhatenterpriseserver", "centos"
        node[:app_passenger][:mysql_packages_install].each do |p|
          package p
       end

      when "ubuntu","debian"
        log "Nothing to do!"
    end
  end


  #creating database template
  log "INFO: Generating database.yml"
  template "#{node[:app_passenger][:deploy_dir].chomp}/current/config/database.yml" do
    owner node[:app_passenger][:apache][:user]
    source "database.yml.erb"
    action :create_if_missing
    cookbook 'app_passenger'
  end

  #setting $RAILS_ENV
  ENV['RAILS_ENV'] = node[:app_passenger][:project][:environment]

  #Creating bash file for manual $RAILS_ENV setup
  log "INFO: Creating bash file for manual $RAILS_ENV setup"
  template "/etc/profile.d/rails_env.sh" do
    mode '0744'
    source "rails_env.erb"
    cookbook 'app_passenger'
  end

end


