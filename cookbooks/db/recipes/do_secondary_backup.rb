#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

db_do_backup "do secondary backup" do
  force node[:db][:backup][:force] == 'true'
  backup_type "secondary"
end

rs_utils_marker :end
