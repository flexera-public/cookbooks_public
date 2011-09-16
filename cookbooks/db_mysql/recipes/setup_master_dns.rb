#
# Cookbook Name:: db_mysql
# Recipe:: setup_master_dns
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin
include_recipe "sys_dns::do_set_private"
rs_utils_marker :end
