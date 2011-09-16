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

# TODO this is a restart because there is a connection issue that needs to be fixed
# global read lock is not released after flush
service "mysql" do
  action :restart
end

include_recipe "db_mysql::setup_replication_privileges"
include_recipe "db_mysql::do_tag_as_master"
include_recipe "db_mysql::setup_master_backup"
# kick-off first backup so that slaves can init from this master
include_recipe "db::do_backup"

rs_utils_marker :end
