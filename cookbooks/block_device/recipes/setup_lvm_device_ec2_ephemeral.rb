block_device "/mnt/storage" do
  provider "block_device_ros"
  cloud "ec2"
  lineage node[:block_device][:lineage]
  action :create
end
