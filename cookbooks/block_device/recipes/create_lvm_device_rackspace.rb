block_device "/mnt/storage" do
  cloud "rackspace"
  provider "block_device_ros"
  action :create
end
