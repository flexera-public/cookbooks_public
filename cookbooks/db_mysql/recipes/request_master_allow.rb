#
# Cookbook Name:: db_mysql
# Recipe:: request_master_allow
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

include_recipe "db_mysql::do_lookup_master"

sys_firewall "Request master database open port 3306 to this slave" do
  machine_tag "rs_dbrepl:master_instance_uuid=#{node[:db_mysql][:current_master]}"
  port 3306
  enable true
  ip_addr node[:cloud][:private_ips][0]
  action :update_request
end

rs_utils_marker :end
