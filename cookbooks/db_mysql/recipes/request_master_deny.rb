#
# Cookbook Name:: db_mysql
# Recipe:: request_master_deny
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

include_recipe "db_mysql::do_lookup_master"
raise "No master DB found" unless node[:db][:current_master_ip] && node[:db][:current_master_uuid] 

sys_firewall "Request master database close port 3306 to this slave" do
  machine_tag "rs_dbrepl:master_instance_uuid=#{node[:db][:current_master_uuid]}"
  port 3306
  enable false
  ip_addr node[:cloud][:private_ips][0]
  action :update_request
end

rs_utils_marker :end
