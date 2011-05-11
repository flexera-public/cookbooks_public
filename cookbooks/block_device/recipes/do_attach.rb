#
# Cookbook Name:: block_device
# Recipe:: default
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

storage_type = node[:block_device][:storage_type] # "volume" or "ros"

block_device "/mnt/storage" do
  provider "block_device_#{storage_type}"
  cloud node[:cloud_provider]
  action :create
  
  # volume only
  volume_size "1"
  stripe_size "1"
  
  # ros only
  storage_account_type  # "s3"|"cloudfiles" 
  storage_account_id 
  storage_account_secret

end

