#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

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
end

#setting $RAILS_ENV
ENV['RAILS_ENV'] = node[:app_passenger][:project][:environment]

#Creating bash file for manual $RAILS_ENV setup
log "INFO: Creating bash file for manual $RAILS_ENV setup"
template "/etc/profile.d/rails_env.sh" do
  mode '0744'
  source "rails_env.erb"
end


rs_utils_marker :end