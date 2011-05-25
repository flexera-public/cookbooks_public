block_device "/mnt/storage" do
  cloud "rackspace"
  provider "block_device_ros"
  lineage node[:rightscale_tools][:lineage]
  storage_account_id node[:rightscale_tools][:storage_account_id]
  storage_account_secret node[:rightscale_tools][:storage_account_secret]
  storage_container node[:rightscale_tools][:storage_container]
  storage_account_type "cloudfiles"
  action :backup
end
