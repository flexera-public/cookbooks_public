#
# Cookbook Name:: db_mysql
# Recipe:: do_restore_and_become_master
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

include_recipe "db::do_restore"
include_recipe "db_mysql::setup_replication_privileges"
include_recipe "db_mysql::do_tag_as_master"
# kick-off first backup so that slaves can init from this master
include_recipe "db::do_backup"
include_recipe "db::do_backup_schedule_enable"

rs_utils_marker :end
