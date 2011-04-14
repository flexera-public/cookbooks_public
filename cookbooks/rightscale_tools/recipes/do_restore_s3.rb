block_device "/mnt/storage" do
  provider "block_device_s3"
  storage_account_id node[:rightscale_tools][:storage_account_id]
  storage_account_secret node[:rightscale_tools][:storage_account_secret]
  storage_container node[:rightscale_tools][:storage_container]
  lineage node[:rightscale_tools][:lineage]
  mount_point "/mnt/storage"
  action :restore
end 
