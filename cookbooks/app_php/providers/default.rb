# Cookbook Name:: app_php
# Provider:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#stop apache
action :stop do
  bash "Stopping apache" do
    flags "-ex"
    code <<-EOH
     /etc/init.d/#{node[:apache][:config_subdir]} stop
    EOH
  end
end

#start apache
action :start do
  bash "Starting apache" do
    flags "-ex"
    code <<-EOH
     /etc/init.d/#{node[:apache][:config_subdir]} start
    EOH
  end
end


action :restart do
  action_stop
     sleep 5
  action_start
end


action :install do

  # == Install user-specified Packages and Modules
  #
  packages = new_resource.packages
  log "Packages which will be installed #{packages}"

  packages.each do |p|
    package p
  end

  node[:php][:modules_list].each do |p|
    package p
  end

  node[:php][:module_dependencies].each do |mod|
    apache_module mod
  end

  ENV['APP_NAME'] = "#{node[:web_apache][:docroot]}}"
  bash "save global vars" do
    flags "-ex"
    code <<-EOH
      echo $APP_NAME >> /tmp/appname
    EOH
  end

end

action :setup_vhost do


  #TODO implement to passenger
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
  end
  action_restart

  # == Configure apache vhost for PHP
  #
  #web_app node[:php][:application_name] do
  web_app node[:web_apache][:application_name] do
    template "app_server.erb"
#    docroot node[:web_apache][:docroot]
    docroot node[:app][:destination]
    vhost_port node[:app][:port]
    server_name node[:web_apache][:server_name]
    cookbook "web_apache"
  end
  action_restart

end

action :setup_db_connection do

  # == Setup PHP Database Connection
  #
  # Make sure config dir exists
  directory ::File.join(node[:web_apache][:docroot], "config") do
    recursive true
    owner node[:php][:app_user]
    group node[:php][:app_user]
  end

  # Tell MySQL to fill in our connection template
  db_mysql_connect_app ::File.join(node[:web_apache][:docroot], "config", "db.php") do
    template "db.php.erb"
    cookbook "app_php"
    database node[:php][:db_schema_name]
    owner node[:php][:app_user]
    group node[:php][:app_user]
  end

end

action :code_update do



     #Reading app name from tmp file (for execution in "operational" phase))
  #Waiting for "run_lists"
  deploy_dir = new_resource.destination

  log "INFO: Creating directory for project deployment - <#{deploy_dir}>"
  directory deploy_dir do
    recursive true
  end

#  if(deploy_dir == "/srv/tomcat6/webapps/")
#    app_name = IO.read('/tmp/appname')
#    deploy_dir = "/srv/tomcat6/webapps/#{app_name.to_s.chomp}"
#  end

  # Check that we have the required attributes set
  log "You must provide a destination for your application code." if ("#{deploy_dir}" == "")

  repo "default" do
    destination deploy_dir
    action :capistrano_pull
    app_user node[:php][:app_user]
    persist false
  end

  action_restart

end








