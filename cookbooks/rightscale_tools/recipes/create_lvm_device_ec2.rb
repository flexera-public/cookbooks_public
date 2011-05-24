block_device "/mnt/storage" do
  provider "block_device_ros"
  cloud "ec2"
  lineage node[:rightscale_tools][:lineage]
  action :create
end
