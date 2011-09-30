#
# Cookbook Name:: db
# Recipe:: do_init_slave
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#
DATA_DIR = node[:db][:data_dir]

rs_utils_marker :begin

raise 'Database already restored.  To over write existing database run do_force_reset before this recipe' if node[:db][:db_restored] 

include_recipe "db::do_lookup_master"
raise "No master DB found" unless node[:db][:current_master_ip] && node[:db][:current_master_uuid] 

include_recipe "db::request_master_allow"

include_recipe "db::do_restore"

db DATA_DIR do
  action :enable_replication
end

include_recipe "db::do_backup"
include_recipe "db::do_backup_schedule_enable"

ruby_block "Setting db_restored state to true" do
  block do
    node[:db][:db_restored] = true
  end
end

rs_utils_marker :end
