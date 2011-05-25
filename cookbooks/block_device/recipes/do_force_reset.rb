storage_type = node[:block_device][:storage_type] # "volume" or "ros"

block_device "/mnt/storage" do
  provider "block_device_#{storage_type}"
  cloud node[:cloud][:provider]
  action :reset
end
