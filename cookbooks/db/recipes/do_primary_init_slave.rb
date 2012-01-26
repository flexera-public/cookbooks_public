#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

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
#   node[:db][:current_master_ec2_id] - for 11H1 migration
r = ruby_block "find current master" do
  block do
    collect = {}
    node[:server_collection]["master_servers"].each do |id, tags|
      active = tags.select { |s| s =~ /rs_dbrepl:master_active/ }
      my_uuid = tags.detect { |u| u =~ /rs_dbrepl:master_instance_uuid/ }
      my_ip_0 = tags.detect { |i| i =~ /server:private_ip_0/ }
      # following used for detecting 11H1 DB servers
      ec2_instance_id = tags.detect { |each_ec2_instance_id| each_ec2_instance_id =~ /ec2:instance_id/ }
      most_recent = active.sort.last
      collect[most_recent] = my_uuid, my_ip_0, ec2_instance_id
    end
    most_recent_timestamp = collect.keys.sort.last
    current_master_uuid, current_master_ip, current_master_ec2_id = collect[most_recent_timestamp]
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

    # following used for detecting 11H1 DB servers
    if current_master_ec2_id
      node[:db][:current_master_ec2_id] = current_master_ec2_id.split(/=/, 2).last.chomp
      Chef::Log.info "Detected #{current_master_ec2_id} - 11H1 migration"
    else
      node[:db][:current_master_ec2_id] = nil
    end

    Chef::Log.info "found current master: #{node[:db][:current_master_uuid]} ip: #{node[:db][:current_master_ip]} active at #{most_recent_timestamp}" if current_master_uuid && current_master_ip
  end
end
r.run_action(:create)

raise "No master DB found" unless node[:db][:current_master_ip] && node[:db][:current_master_uuid]

include_recipe "db::request_master_allow"

include_recipe "db::do_primary_restore"

db DATA_DIR do
  action :enable_replication
end

# Configure monitoring for slave setup
db DATA_DIR do
  action :setup_monitoring
end

# Force a new backup
db_do_backup "do force backup" do
  force true
end

include_recipe "db::do_primary_backup_schedule_enable"

rs_utils_marker :end
