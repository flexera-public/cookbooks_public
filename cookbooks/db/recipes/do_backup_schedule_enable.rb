log "==================== #{self.cookbook_name}::#{self.recipe_name} : Begin ===================="
DATA_DIR = "/mnt/storage"

snap_lineage = node[:db][:backup][:lineage]
raise "ERROR: 'Backup Lineage' required for scheduled process" if snap_lineage.empty?

block_device DATA_DIR do
  lineage snap_lineage
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  action :backup_schedule_enable
end

log "==================== #{self.cookbook_name}::#{self.recipe_name} : End ===================="