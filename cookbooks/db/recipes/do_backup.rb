log "==================== #{self.cookbook_name}::#{self.recipe_name} : Begin ===================="
DATA_DIR = node[:db][:data_dir]

log "  Performing pre-backup check, then lock DB..."
db DATA_DIR do
  action [ :pre_backup_check, :lock ]
end

log "  Performing Backup..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :backup
end

log "  Performing unlock DB, the perform post-backup cleanup..."
db DATA_DIR do
  action [ :unlock, :post_backup_cleanup ]
end

log "==================== #{self.cookbook_name}::#{self.recipe_name} : End ===================="
