#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

NICKNAME = node[:block_device][:nickname]

# == Verify initalized database
# Check the node state to verify that we have correctly initialized this server.
db_state_assert :either

snap_lineage = node[:db][:backup][:lineage]
raise "ERROR: 'Backup Lineage' required for scheduled process" if snap_lineage.empty?

if node[:db][:this_is_master]
  hour = node[:db][:backup][:primary][:master][:cron][:hour]
  minute = node[:db][:backup][:primary][:master][:cron][:minute]
  type = "Master"
else
  hour = node[:db][:backup][:primary][:slave][:cron][:hour]
  minute = node[:db][:backup][:primary][:slave][:cron][:minute]
  type = "Slave"
end

log "  Setting up #{type} primary backup cron job to run at hour: #{hour} and minute #{minute}"
block_device NICKNAME do
  lineage snap_lineage
  cron_backup_recipe "#{self.cookbook_name}::do_primary_backup"
  cron_backup_hour hour.to_s
  cron_backup_minute minute.to_s
  action :backup_schedule_enable
end

rs_utils_marker :end
