rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]
CLOUD = (node[:db][:backup][:secondary_location] == "CloudFiles") ? "cloudfiles" : "ec2" 

log "  Performing pre-backup check, then lock DB..."
db DATA_DIR do
  action [ :pre_backup_check, :lock ]
end

log "  Performing Backup..."
# Requires block_device DATA_DIR to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  provider "block_device_ros"
  storage_container node[:db][:backup][:secondary_container]
  cloud CLOUD
  persist false
  action :backup
end

log "  Performing unlock DB, the perform post-backup cleanup..."
db DATA_DIR do
  action [ :unlock, :post_backup_cleanup ]
end

rs_utils_marker :end