#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# == Setup PHP Database Connection
#
# Make sure config dir exists
directory File.join(node[:web_apache][:docroot], "config") do
  recursive true 
  owner node[:php][:app_user]
  group node[:php][:app_user]
end

# Tell MySQL to fill in our connection template
db_mysql_connect_app File.join(node[:web_apache][:docroot], "config", "db.php") do
  template "db.php.erb"
  cookbook "app_php"
  database node[:php][:db_schema_name]
  owner node[:php][:app_user]
  group node[:php][:app_user]
end

rs_utils_marker :end
