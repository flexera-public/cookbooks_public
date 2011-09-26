#
# Cookbook Name:: db_mysql
# Recipe:: setup_slave_backup
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

include_recipe "db::do_backup_schedule_enable"

rs_utils_marker :end
