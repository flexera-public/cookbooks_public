block_device "/mnt/storage" do
  cloud "rackspace"
  provider "block_device_ros"
  lineage node[:block_device][:lineage]
  storage_account_id node[:block_device][:storage_account_id]
  storage_account_secret node[:block_device][:storage_account_secret]
  storage_container node[:block_device][:storage_container]
  storage_type node[:block_device][:storage_type]
  action :backup
end
