#
# Cookbook Name:: db
# Recipe:: do_promote_to_master
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

# == Find current master
#
include_recipe 'db::do_lookup_master'

# == Initial checks 
#
# Make sure we are not already master. 
# 
ruby_block "slave check" do
  block do
    raise "FATAL: this instance is already a master!" if node[:db][:this_is_master]
    # The master could be terminated.  Warn the user and plow ahead and try to become master.
    Chef::Log.warn "WARNING: Unable to lookup current master server UUID" unless node[:db][:current_master_uuid]
    Chef::Log.warn "WARNING: Unable to lookup current master server IP" unless node[:db][:current_master_ip]
  end
end

# == Open port for slave replication by old-master
#
# TODO determine if the old master is still up and we should open the port to it
#
sys_firewall "Open port 3306 to the old master which is becoming a slave" do
  port 3306
  enable true
  ip_addr node[:db][:current_master_ip]
  action :update
end

# == Change the tags, but, leave the current_master* from last db::do_lookup_master node attributes so they can be used for "previous" master
#
include_recipe 'db::do_tag_as_master'
include_recipe "db::setup_replication_privileges"

db node[:db][:data_dir] do
  action :promote
end

# == Schedule backups on slave
# This should be done before calling db::do_lookup_master 
# changes current_master from old to new. 
# 
remote_recipe "enable slave backups on oldmaster" do
  recipe "db::do_backup_schedule_enable"
  recipients_tags "rs_dbrepl:master_instance_uuid=#{node[:db][:current_master_uuid]}"
end

# == Schedule master backups
# Now do the lookup to setup the current_master in the node
# then enable the backups locally.
#
include_recipe 'db::do_lookup_master'
include_recipe 'db::do_backup'
include_recipe "db::do_backup_schedule_enable"

rs_utils_marker :end