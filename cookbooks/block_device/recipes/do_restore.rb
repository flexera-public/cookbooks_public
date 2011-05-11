#
# Cookbook Name:: block_device
# Recipe:: do_restore
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

storage_type = node[:block_device][:storage_type] # "volume" or "ros"

block_device "/mnt/storage" do
  provider "block_device_#{storage_type}"
  cloud node[:cloud_provider]
  action :backup
  
  lineage #TODO
  timestamp_override #TODO
  
  # ros only
  storage_account_type  #TODO
  storage_account_id  #TODO
  storage_account_secret  #TODO
  storage_account_container #TODO
  
end

