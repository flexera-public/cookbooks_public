#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

# == Verify initalized database
# Check the node state to verify that we have correctly initialized this server.
db_state_assert :either

snap_lineage = node[:db][:backup][:lineage]
raise "ERROR: 'Backup Lineage' required for scheduled process" if snap_lineage.empty?

# TODO: fix for LAMP
if node[:db][:this_is_master]
  hour = node[:db][:backup][:master][:hour]
  minute = node[:db][:backup][:master][:minute]
else
  hour = node[:db][:backup][:slave][:hour]
  minute = node[:db][:backup][:slave][:minute]
end

block_device DATA_DIR do
  lineage snap_lineage
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  cron_backup_hour hour.to_s
  cron_backup_minute minute.to_s
  action :backup_schedule_enable
end

rs_utils_marker :end
