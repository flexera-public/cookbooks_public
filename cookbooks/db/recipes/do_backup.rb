rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

log "  Performing pre-backup check, then lock DB..."
db DATA_DIR do
  action [ :pre_backup_check, :lock ]
end

log "  Performing Snapshot..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :snapshot
end

log "  Performing unlock DB..."
db DATA_DIR do
  action :unlock
end

log "  Performing Backup..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :backup
end

log "  Performing post-backup cleanup..."
db DATA_DIR do
  action :post_backup_cleanup
end

rs_utils_marker :end
