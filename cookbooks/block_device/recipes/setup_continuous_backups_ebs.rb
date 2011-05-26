log "Enabling continuous backups to EBS via cron job:#{node[:block_device][:cron_backup_minute]} #{node[:block_device][:cron_backup_hour]}"
cron "RightScale continuous backups EBS" do
  minute "#{node[:block_device][:cron_backup_minute]}"
  hour "#{node[:block_device][:cron_backup_hour]}"
  user "root"
  command "rs_run_recipe -n \"block_device::do_backup_ebs\" 2>&1 > /var/log/rightscale_tools_cron_backup.log"
  action :create
end
