#
# Cookbook Name:: app_rails
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# restore application database schema from remote location
db_mysql_restore "do database restore" do
  url node[:rails][:code][:url]
  branch node[:rails][:code][:branch] 
  credentials node[:rails][:code][:credentials]
  file_path node[:rails][:db_mysqldump_file_path]
  schema_name node[:rails][:db_schema_name]
end

db_mysql_set_privileges "setup user privileges" do
  preset 'user'
  username node[:rails][:db_app_user]
  password node[:rails][:db_app_passwd]
end

rs_utils_marker :end
