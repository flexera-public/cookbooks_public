#
# Cookbook Name:: db_mysql
# Recipe:: do_lookup_master
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

r = server_collection "master_servers" do
  tags [ "rs_dbrepl:" ]
end
r.run_action(:load)

# Finds the current master and sets the node attrib for node[:db_mysql][:current_master]
# ALSO: sets up special variable :this_is_master
r = ruby_block "find current master" do
  block do
    collect = {}
    node[:server_collection]["master_servers"].each do |id, tags|
      active = tags.select { |s| s =~ /rs_dbrepl:master_active/ }
      my_uuid = tags.detect { |u| u =~ /rs_dbrepl:master_instance_uuid/ }
      most_recent = active.sort.last
      collect[most_recent] = my_uuid
    end
    most_recent_timest = collect.keys.sort.last
    current_master_uuid = collect[most_recent_timest]
    if current_master_uuid =~ /#{node[:rightscale][:instance_uuid]}/
      Chef::Log.info "THIS instance is the current master"
      node[:db_mysql][:this_is_master] = true
    else
      node[:db_mysql][:this_is_master] = false
    end
    if current_master_uuid
      node[:db_mysql][:current_master] = current_master_uuid.split(/=/, 2).last.chomp if current_master_uuid
      Chef::Log.info "found current master: #{node[:db_mysql][:current_master]} active at #{most_recent_timest}"
    else
      Chef::Log.warn "no current master db found"
      raise "No current master db found"
    end
  end
end
r.run_action(:create)

rs_utils_marker :end
