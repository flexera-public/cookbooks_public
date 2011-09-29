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

# Finds the current master and sets the node attribs for 
#   node[:db_mysql][:current_master_uuid]
#   node[:db_mysql][:current_master_ip]
#   node[:db_mysql][:this_is_master]
r = ruby_block "find current master" do
  block do
    collect = {}
    node[:server_collection]["master_servers"].each do |id, tags|
      Chef::Log.info "======== TAGS ========"
      Chef::Log.info id
      Chef::Log.info tags
      Chef::Log.info "======== TAGS ========"
      active = tags.select { |s| s =~ /rs_dbrepl:master_active/ }
      my_uuid = tags.detect { |u| u =~ /rs_dbrepl:master_instance_uuid/ }
      my_ip_0 = tags.detect { |i| i =~ /server:private_ip_0/ }
      most_recent = active.sort.last
      collect[most_recent] = my_uuid, my_ip_0
      Chef::Log.info "DEBUG: Server collecttion master_servers: active #{active} uuid: #{my_uuid} ip_0: #{my_ip_0} most_recent #{most_recent} collect #{collect[most_recent]}"
    end
    most_recent_timestamp = collect.keys.sort.last
    current_master_uuid, current_master_ip = collect[most_recent_timestamp]
    if current_master_uuid =~ /#{node[:rightscale][:instance_uuid]}/
      Chef::Log.info "THIS instance is the current master"
      node[:db_mysql][:this_is_master] = true
    else
      node[:db_mysql][:this_is_master] = false
    end
    if current_master_uuid
      node[:db_mysql][:current_master_uuid] = current_master_uuid.split(/=/, 2).last.chomp
    else
      node[:db_mysql][:current_master_uuid] = nil
      Chef::Log.info "No current master db found"
    end
    if current_master_ip
      node[:db_mysql][:current_master_ip] = current_master_ip.split(/=/, 2).last.chomp
    else
      node[:db_mysql][:current_master_ip] = nil
      Chef::Log.info "No current master ip found"
    end
    Chef::Log.info "found current master: #{node[:db_mysql][:current_master_uuid]} ip: #{node[:db_mysql][:current_master_ip]} active at #{most_recent_timestamp}" if current_master_uuid && current_master_ip
  end
end
r.run_action(:create)

rs_utils_marker :end
