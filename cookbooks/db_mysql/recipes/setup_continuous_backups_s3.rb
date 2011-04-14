log "Enabling continuous backups to S3 via cron job:#{node[:db_mysql][:backup][:cron_backup_minute]} #{node[:db_mysql][:backup][:cron_backup_hour]}"
cron "RightScale continuous backups S3" do
  minute "#{node[:db_mysql][:backup][:cron_backup_minute]}"
  hour "#{node[:db_mysql][:backup][:cron_backup_hour]}"
  user "root"
  command "rs_run_recipe -n \"block_device::do_backup_s3\" 2>&1 > /var/log/rightscale_tools_cron_backup.log"
  action :create
end
