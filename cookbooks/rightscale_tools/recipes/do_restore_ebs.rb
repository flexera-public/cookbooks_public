block_device "/mnt/storage" do
  provider "block_device_volume"
  cloud "ec2"
  #volume_size "1"
  #stripe_size "1"
  lineage node[:rightscale_tools][:lineage]
  action :restore
end
