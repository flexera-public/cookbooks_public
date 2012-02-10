#
# Cookbook Name::app_passenger
# Recipe do_update_code
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

 #Reading app name from tmp file (for execution in "operational" phase))
  if(node[:app_passenger][:deploy_dir]=="/home/rails/")
    app_name = IO.read('/tmp/appname')
    node[:app_passenger][:deploy_dir]="/home/rails/#{app_name.to_s.chomp}"
  end

  # Preparing dirs, required for apache+passenger
  log "INFO: Creating directory for project deployment - <#{node[:app_passenger][:deploy_dir]}>"
  directory node[:app_passenger][:deploy_dir] do
    recursive true
  end


  directory "#{node[:app_passenger][:deploy_dir].chomp}/shared/log" do
    recursive true
  end

  directory "#{node[:app_passenger][:deploy_dir].chomp}/shared/system" do
    recursive true
  end

  repo "default" do
    destination node[:app_passenger][:deploy_dir]
    action :capistrano_pull
    app_user node[:app_passenger][:apache][:user]
    environment "RAILS_ENV" => "#{node[:app_passenger][:project][:environment]}"
    create_dirs_before_symlink
  end

rs_utils_marker :end