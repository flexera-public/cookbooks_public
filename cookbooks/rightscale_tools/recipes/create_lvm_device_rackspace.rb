block_device "/mnt/storage" do
  provider "block_device_cloud_files"
  mount_point "/mnt/storage"
  volume_size "1"
  stripe_size "1"
  surround_with "none"
  action :create
end
