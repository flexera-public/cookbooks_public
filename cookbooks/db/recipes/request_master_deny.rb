#
# Cookbook Name:: db
# Recipe:: request_master_deny
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

# == Lookup current master
#
include_recipe "db::do_lookup_master"
master_ip = node[:db][:current_master_ip]
master_uuid = node[:db][:current_master_uuid]
raise "No master DB found" unless master_ip && master_uuid

# == Request firewall closed
#
db node[:db][:data_dir] do
  machine_tag "rs_dbrepl:master_instance_uuid=#{master_uuid}"
  enable false
  ip_addr node[:cloud][:private_ips][0]
  action :allow_request
end

rs_utils_marker :end
