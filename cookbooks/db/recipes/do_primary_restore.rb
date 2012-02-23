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

class Chef::Resource::BlockDevice
  include RightScale::BlockDeviceHelper
end

DATA_DIR = node[:db][:data_dir]
NICKNAME = get_device_or_default(node, :device1, :nickname)

db_init_status :check do
  expected_state :uninitialized
  error_message "Database already restored.  To over write existing database run do_force_reset before this recipe"
end

log "  Running pre-restore checks..."
db DATA_DIR do
  action :pre_restore_check
end

if node[:db][:backup][:lineage_override].empty?
  backup_lineage = node[:db][:backup][:lineage]
else
  log "** USING LINEAGE OVERRIDE **"
  backup_lineage = node[:db][:backup][:lineage_override]
end

log "======== LINEAGE ========="
log backup_lineage
log "======== LINEAGE ========="

log "  Stopping database..."
db DATA_DIR do
  action :stop
end

log "  Performing Restore..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device NICKNAME do
  lineage node[:db][:backup][:lineage]
  lineage_override node[:db][:backup][:lineage_override]
  timestamp_override node[:db][:backup][:timestamp_override]
  volume_size get_device_or_default(node, :device1, :volume_size)
  action :primary_restore
end

log "  Running post-restore cleanup..."
db DATA_DIR do
  action :post_restore_cleanup
end

log "  Setting state of database to be 'initialized'..."
db_init_status :set

log "  Starting database..."
db DATA_DIR do
  action [ :start, :status ]
end

rs_utils_marker :end
