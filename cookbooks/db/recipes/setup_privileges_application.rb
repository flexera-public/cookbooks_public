#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

user = node[:db][:application][:user]
log "Adding #{user} with CRUD privileges for all databases."

db DATA_DIR do
  privilege "user"
  privilege_username user
  privilege_password node[:db][:application][:password]
  privilege_database "*.*" # All databases
  action :set_privileges
end

rs_utils_marker :end
