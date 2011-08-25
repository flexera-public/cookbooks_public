log "==================== #{self.cookbook_name}::#{self.recipe_name} : Begin ===================="
DATA_DIR = node[:db][:data_dir]

log "  Stopping database..."
db DATA_DIR do
  action :stop
end

log "  Creating block device..."
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :create
end

log "  Moving database to block device and starting database..."
db DATA_DIR do
	action [ :move_data_dir, :start ]
end
log "==================== #{self.cookbook_name}::#{self.recipe_name} : End ===================="
