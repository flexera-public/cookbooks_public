block_device "/mnt/storage" do
  provider "block_device_cloud_files"
  mount_point "/mnt/storage"
  action :reset
end
