#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

include_recipe "db::do_restore"

db_register_master

include_recipe "db::setup_replication_privileges"
# force first backup so that slaves can init from this master
db_do_backup "do force backup" do
  force true
end

include_recipe "db::do_backup_schedule_enable"

rs_utils_marker :end
