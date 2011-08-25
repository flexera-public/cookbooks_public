rs_utils_marker :begin

DATA_DIR = "/mnt/storage"

block_device DATA_DIR do
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  action :backup_schedule_disable
end

rs_utils_marker :end