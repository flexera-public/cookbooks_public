block_device "/mnt/storage" do
  provider "block_device_ebs"
  mount_point "/mnt/storage"
  volume_size "1"
  stripe_size "1"
  surround_with "none"
  max_snapshots node[:rightscale_tools][:max_snapshots]
  keep_daily node[:rightscale_tools][:keep_daily]
  keep_weekly node[:rightscale_tools][:keep_weekly]
  keep_monthly node[:rightscale_tools][:keep_monthly]
  keep_yearly node[:rightscale_tools][:keep_yearly]
  action :backup
end
