block_device "/mnt/storage" do
  provider "block_device_s3"
  lineage node[:rightscale_tools][:lineage]
  storage_account_id node[:rightscale_tools][:storage_account_id]
  storage_account_secret node[:rightscale_tools][:storage_account_secret]
  storage_container node[:rightscale_tools][:storage_container]
  max_snapshots node[:rightscale_tools][:max_snapshots]
  keep_daily node[:rightscale_tools][:keep_daily]
  keep_weekly node[:rightscale_tools][:keep_weekly]
  keep_monthly node[:rightscale_tools][:keep_monthly]
  keep_yearly node[:rightscale_tools][:keep_yearly]
  mount_point "/mnt/storage"
  action :backup
end
