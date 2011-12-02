#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

db_init_status :check do
  expected_state :uninitialized
  error_message "Database already restored.  To over write existing database run do_force_reset before this recipe"
end

log "  Running pre-restore checks..."
db DATA_DIR do
  action :pre_restore_check
end

log "======== LINEAGE ========="
log node[:db][:backup][:lineage]
log "======== LINEAGE ========="

# ROS restore requires a setup, but VOLUME restore does not.
# Only Rackpspace uses ROS backups
if node[:cloud][:provider] == "rackspace"
  log "  Creating block device..."
  block_device DATA_DIR do
    lineage node[:db][:backup][:lineage]
    action :create
  end
end

log "  Stopping database..."
db DATA_DIR do
  action :stop
end

log "  Performing Restore..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  timestamp_override node[:db][:backup][:timestamp_override]
  cloud node[:cloud][:provider]
  rackspace_snet node[:block_device][:rackspace_snet]
  action :restore
end

log "  Setting state of database to be 'initialized'..."
db_init_status :set

log "  Running post-restore cleanup..."
db DATA_DIR do
  action :post_restore_cleanup
end

log "  Starting database as master..."
db DATA_DIR do
  action [ :start, :status ]
end

rs_utils_marker :end
