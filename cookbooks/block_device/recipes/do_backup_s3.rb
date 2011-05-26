block_device "/mnt/storage" do
  provider "block_device_ros"
# cloud is only necessary for create* but something is requiring it
  cloud "ec2"
  storage_type "s3"
  lineage node[:block_device][:lineage]
  storage_account_id node[:block_device][:storage_account_id]
  storage_account_secret node[:block_device][:storage_account_secret]
  storage_container node[:block_device][:storage_container]
  max_snapshots node[:block_device][:max_snapshots]
  keep_daily node[:block_device][:keep_daily]
  keep_weekly node[:block_device][:keep_weekly]
  keep_monthly node[:block_device][:keep_monthly]
  keep_yearly node[:block_device][:keep_yearly]
  action :backup
end
