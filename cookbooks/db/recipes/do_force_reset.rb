log "==================== #{self.cookbook_name}::#{self.recipe_name} : Begin ===================="
DB_DATA = node[:db][:data_dir]

log "  Stopping database..."
db DB_DATA do
  action :stop
end

log "  Resetting block device..."
block_device DB_DATA do
  action :reset
end

log "  Resetting database, then starting database..."
db DB_DATA do
	action [ :reset, :start ]
end
log "==================== #{self.cookbook_name}::#{self.recipe_name} : End ===================="
