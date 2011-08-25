rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

log "  Stopping database..."
db DATA_DIR do
  action :stop
end

log "  Resetting block device..."
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :reset
end

log "  Resetting database, then starting database..."
db DATA_DIR do
	action [ :reset, :start ]
end

rs_utils_marker :begin
