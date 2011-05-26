block_device "/mnt/storage" do
  provider "block_device_ros"
  cloud "ec2"
  storage_type "s3"
  storage_account_id node[:block_device][:storage_account_id]
  storage_account_secret node[:block_device][:storage_account_secret]
  storage_container node[:block_device][:storage_container]
  lineage node[:block_device][:lineage]
  action :restore
end 
