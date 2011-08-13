log "==================== #{self.cookbook_name}::#{self.recipe_name} : Begin ===================="
DATA_DIR = "/mnt/storage"

block_device DATA_DIR do
  recipe "#{self.cookbook_name}::do_backup"
  action :backup_schedule_disable
end

log "==================== #{self.cookbook_name}::#{self.recipe_name} : End ===================="