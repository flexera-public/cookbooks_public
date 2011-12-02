#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

DATA_DIR = node[:db][:data_dir]

rs_utils_marker :begin

log "  Checking if state of database is'uninitialized'..."
db_init_status :check do
  expected_state :uninitialized
  error_message "Database already restored.  To over write existing database run do_force_reset before this recipe"
end

r = rs_utils_server_collection "master_servers" do
  tags ['rs_dbrepl:master_active', 'rs_dbrepl:master_instance_uuid']
  secondary_tags 'server:private_ip_0'
  action :nothing
end
r.run_action(:load)

# Finds the current master and sets the node attribs for 
#   node[:db][:current_master_uuid]
#   node[:db][:current_master_ip]
#   node[:db][:this_is_master]
r = ruby_block "find current master" do
  block do
    collect = {}
    node[:server_collection]["master_servers"].each do |id, tags|
      active = tags.select { |s| s =~ /rs_dbrepl:master_active/ }
      my_uuid = tags.detect { |u| u =~ /rs_dbrepl:master_instance_uuid/ }
      my_ip_0 = tags.detect { |i| i =~ /server:private_ip_0/ }
      most_recent = active.sort.last
      collect[most_recent] = my_uuid, my_ip_0
      #Chef::Log.info "DEBUG: Server collection master_servers: active #{active} uuid: #{my_uuid} ip_0: #{my_ip_0} most_recent #{most_recent} collect #{collect[most_recent]}"
    end
    most_recent_timestamp = collect.keys.sort.last
    current_master_uuid, current_master_ip = collect[most_recent_timestamp]
    if current_master_uuid =~ /#{node[:rightscale][:instance_uuid]}/
      Chef::Log.info "THIS instance is the current master"
      node[:db][:this_is_master] = true
    else
      node[:db][:this_is_master] = false
    end
    if current_master_uuid
      node[:db][:current_master_uuid] = current_master_uuid.split(/=/, 2).last.chomp
    else
      node[:db][:current_master_uuid] = nil
      Chef::Log.info "No current master db found"
    end
    if current_master_ip
      node[:db][:current_master_ip] = current_master_ip.split(/=/, 2).last.chomp
    else
      node[:db][:current_master_ip] = nil
      Chef::Log.info "No current master ip found"
    end
    Chef::Log.info "found current master: #{node[:db][:current_master_uuid]} ip: #{node[:db][:current_master_ip]} active at #{most_recent_timestamp}" if current_master_uuid && current_master_ip
  end
end
r.run_action(:create)

raise "No master DB found" unless node[:db][:current_master_ip] && node[:db][:current_master_uuid] 

include_recipe "db::request_master_allow"

include_recipe "db::do_restore"

db DATA_DIR do
  action :enable_replication
end

# Force a new backup
db_do_backup "do force backup" do
  force true
end

include_recipe "db::do_backup_schedule_enable"

rs_utils_marker :end
