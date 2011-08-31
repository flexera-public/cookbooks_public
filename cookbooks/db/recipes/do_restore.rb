rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

log "  Running pre-restore checks..."
db DATA_DIR do
  action :pre_restore_check
end

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
  action :restore
end

log "  Running post-restore cleanup..."
db DATA_DIR do
  action :post_restore_cleanup
end

log "  Starting database as master..."
db DATA_DIR do
  action [ :start, :status ]
end

# TODO: replication not yet supported
# log "  Setup replication grants..."
# db DATA_DIR do
#   action [ :set_replication_grants ]
# end

rs_utils_marker :end
