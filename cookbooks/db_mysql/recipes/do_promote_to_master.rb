#
# Cookbook Name:: db_mysql
# Recipe:: do_promote_to_master
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

#include_recipe 'db_mysql::do_lookup_master'

# Find current master
ruby_block "slave check" do
  block do
    raise "FATAL: this instance is already a master!" if node[:db_mysql][:this_is_master]
    # The master could be terminated.  Warn the user and plow ahead and try to become master.
    Chef::Log.warn "WARNING: Unable to lookup current master server UUID" unless node[:db_mysql][:current_master_uuid]
    Chef::Log.warn "WARNING: Unable to lookup current master server IP" unless node[:db_mysql][:current_master_ip]
  end
end

x = node[:db_mysql][:log_bin]
logbin_dir = x.gsub(/#{::File.basename(x)}$/, "")
directory logbin_dir do
  action :create
  recursive true
  owner 'mysql'
  group 'mysql'
end

# Set read/write in my.cnf
node[:db_mysql][:tunable][:read_only] = 0
# Enable binary logging in my.cnf
node[:db_mysql][:log_bin_enabled] = true

template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :server_id => node[:db_mysql][:server_id]
  )
  cookbook 'db_mysql'
end


# Change the tags, but, leave the current_master* node attributes so they can be used for "previous" master
include_recipe 'db_mysql::do_tag_as_master'
include_recipe "db_mysql::setup_replication_privileges"

db node[:db][:data_dir] do
  action :promote
end

# Now do the lookup to setup the current_master
include_recipe 'db_mysql::do_lookup_master'
include_recipe 'db_mysql::setup_master_backup'
# used to skip pre_backup_sanity_check
node[:db][:backup][:force] = true
include_recipe 'db::do_backup'
node[:db][:backup][:force] = false

remote_recipe "enable slave backups on oldmaster" do
  recipe "db_mysql::setup_slave_backup"
  recipients_tags "rs_dbrepl:master_instance_uuid=#{node[:db_mysql][:current_master_uuid]}"
end

rs_utils_marker :end
