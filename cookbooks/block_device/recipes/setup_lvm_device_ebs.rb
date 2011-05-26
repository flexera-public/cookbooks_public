block_device "/mnt/storage" do
  provider "block_device_volume"
  cloud "ec2"
  volume_size "1"
  stripe_size "1"
  lineage node[:block_device][:lineage]
  action :create
end
