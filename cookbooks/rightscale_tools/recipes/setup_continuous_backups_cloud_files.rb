log "Enabling continuous backups to RackSpace CloudFiles via cron job:#{node[:rightscale_tools][:cron_backup_minute]} #{node[:rightscale_tools][:cron_backup_hour]}"
cron "RightScale continuous backups CloudFiles" do
  minute "#{node[:rightscale_tools][:cron_backup_minute]}"
  hour "#{node[:rightscale_tools][:cron_backup_hour]}"
  user "root"
  command "rs_run_recipe -n \"rightscale_tools::do_backup_s3\" 2>&1 > /var/log/rightscale_tools_cron_backup.log"
  action :create
end
