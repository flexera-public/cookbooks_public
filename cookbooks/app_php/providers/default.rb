#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop apache
action :stop do
  log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end


# Start apache
action :start do
    log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end


# Restart apache
action :restart do
  action_stop
     sleep 5
  action_start
end


action :install do
  # Install user-specified Packages and Modules
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
  # Saving project name variables for use in operational mode
  node[:app][:destination]="#{node[:web_apache][:docroot]}"
  ENV['APP_NAME'] = "#{node[:web_apache][:docroot]}}"
  bash "save global vars" do
    flags "-ex"
    code <<-EOH
      echo $APP_NAME >> /tmp/appname
    EOH
  end

end


# Setup apache PHP virtual host
action :setup_vhost do

  project_root = new_resource.destination
  php_port = new_resource.port

  # Disable default vhost
  apache_site "000-default" do
    enable false
  end

  # Adds php port to list of ports for webserver to listen on
  app_add_listen_port php_port
  
  # Configure apache vhost for PHP
  web_app node[:web_apache][:application_name] do
    template "app_server.erb"
    docroot project_root
    vhost_port php_port.to_s
    server_name node[:web_apache][:server_name]
    cookbook "web_apache"
  end

end


# Setup PHP Database Connection
action :setup_db_connection do
  project_root = new_resource.destination
  # Make sure config dir exists
  directory ::File.join(project_root, "config") do
    recursive true
    owner node[:php][:app_user]
    group node[:php][:app_user]
  end

  db_adapter = node[:php][:db_adapter]
  # runs only on db_adapter selection
  if db_adapter == "mysql"
    # Tell MySQL to fill in our connection template
    db_mysql_connect_app ::File.join(project_root, "config", "db.php") do
      template "db.php.erb"
      cookbook "app_php"
      database node[:php][:db_schema_name]
      owner node[:php][:app_user]
      group node[:php][:app_user]
    end
  elsif db_adapter == "postgresql"
    # Tell PostgreSQL to fill in our connection template
    db_postgres_connect_app ::File.join(project_root, "config", "db.php") do
      template "db.php.erb"
      cookbook "app_php"
      database node[:php][:db_schema_name]
      owner node[:php][:app_user]
      group node[:php][:app_user]
    end
  else
    raise "Unrecognized database adapter #{node[:php][:db_adapter]}, exiting "
  end
end

# Download/Update application repository
action :code_update do

  deploy_dir = new_resource.destination

  # Reading app name from tmp file (for execution in "operational" phase))
  # Waiting for "run_lists"
  if(deploy_dir == "")
    app_name = IO.read('/tmp/appname')
    deploy_dir = "#{app_name.to_s.chomp}"
  end

  log "  Creating directory for project deployment - <#{deploy_dir}>"
  directory "/home/webapp/" do
    recursive true
    not_if do ::File.exists?("/home/webapp/")  end
  end

  # Check that we have the required attributes set
  log "You must provide a destination for your application code." if ("#{deploy_dir}" == "")

  log "  Starting source code download sequence..."
  repo "default" do
    destination deploy_dir
    action :capistrano_pull
    app_user node[:php][:app_user]
    persist false
  end

  # Restarting apache
  action_restart

end
