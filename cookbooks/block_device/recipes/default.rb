#
# Cookbook Name:: block_device
# Recipe:: do_attach
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

Gem.clear_paths
require "rightscale_tools"

storage_type = node[:block_device][:storage_type] # "volume" or "ros"

block_device "/mnt/storage" do
  provider "block_device_#{storage_type}"
  cloud node[:cloud][:provider]
  action :create
  
  # volume only
  volume_size "1"
  stripe_size "1"

end

