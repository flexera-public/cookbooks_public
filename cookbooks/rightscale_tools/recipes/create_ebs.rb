block_device "/mnt/storage" do
  provider "block_device_ebs"
  mount_point "/mnt/storage"
  volume_size "1"
  stripe_size "1"
  surround_with "none"
  action :create
end
