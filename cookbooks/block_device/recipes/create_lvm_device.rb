
case node[:cloud_provider]
when "ec2"
  
  case node[:rightscale_tools][:storage_type]
  when "ebs"
    block_device "/mnt/storage" do
      provider "block_device_ebs"
      mount_point "/mnt/storage"
      volume_size "1"
      stripe_size "1"
      lineage node[:rightscale_tools][:lineage]
      action :create
    end
  when "s3"
    block_device "/mnt/storage" do
      provider "block_device_s3"
      mount_point "/mnt/storage"
      volume_size "1"
      stripe_size "1"
      surround_with "none"
      action :create
    end
  end
  
when "rackspace"
  block_device "/mnt/storage" do
    provider "block_device_cloud_files"
    mount_point "/mnt/storage"
    volume_size "1"
    stripe_size "1"
    surround_with "none"
    action :create
  end
  
end