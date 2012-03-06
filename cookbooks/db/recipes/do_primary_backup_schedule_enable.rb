#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

NICKNAME = get_device_or_default(node, :device1, :nickname)

# == Verify initalized database
# Check the node state to verify that we have correctly initialized this server.
db_state_assert :either

snap_lineage = node[:db][:backup][:lineage]
raise "ERROR: 'Backup Lineage' required for scheduled process" if snap_lineage.empty?

master_hour = node[:db][:backup][:primary][:master][:cron][:hour].to_s
master_minute = node[:db][:backup][:primary][:master][:cron][:minute].to_s
slave_hour = node[:db][:backup][:primary][:slave][:cron][:hour].to_s
slave_minute = node[:db][:backup][:primary][:slave][:cron][:minute].to_s

log "  Setting up Master primary backup cron job to run at hour: #{master_hour} and minute #{master_minute}" do
  only_if { node[:db][:this_is_master] }
end
block_device NICKNAME do
  only_if { node[:db][:this_is_master] }
  lineage snap_lineage
  cron_backup_recipe "db::do_primary_backup"
  cron_backup_hour master_hour
  cron_backup_minute master_minute
  persist false
  action :backup_schedule_enable
end

log "  Setting up Slave primary backup cron job to run at hour: #{slave_hour} and minute #{slave_minute}" do
  not_if { node[:db][:this_is_master] }
end
block_device NICKNAME do
  only_if { true }
  not_if { node[:db][:this_is_master] }
  lineage snap_lineage
  cron_backup_recipe "db::do_primary_backup"
  cron_backup_hour slave_hour
  cron_backup_minute slave_minute
  persist false
  action :backup_schedule_enable
end

rs_utils_marker :end
