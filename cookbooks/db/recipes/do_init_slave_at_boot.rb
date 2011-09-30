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

if node[:db][:init_slave_at_boot]
  log "  Initializing slave at boot..."
  include_recipe "db::do_init_slave"
else
  log "  Initialize slave at boot [skipped]"
end
rs_utils_marker :end
