block_device "/mnt/storage" do
  provider "block_device_volume"
  cloud "ec2"
  lineage node[:block_device][:lineage]
  volume_size "1"
  stripe_size "1"
  max_snapshots node[:block_device][:max_snapshots]
  keep_daily node[:block_device][:keep_daily]
  keep_weekly node[:block_device][:keep_weekly]
  keep_monthly node[:block_device][:keep_monthly]
  keep_yearly node[:block_device][:keep_yearly]
  action :backup
end
