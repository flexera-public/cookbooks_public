block_device "/mnt/storage" do
  provider "block_device_ros"
  cloud "ec2"
  storage_account_type "s3"
  action :reset
end

block_device "/mnt/storage" do
  provider "block_device_volume"
  cloud "ec2"
  action :reset
end
