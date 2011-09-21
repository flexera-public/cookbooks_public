#
# Cookbook Name:: db_mysql
# Recipe:: do_init_slave
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

include_recipe "db_mysql::do_lookup_master"
include_recipe "db_mysql::request_master_allow"
include_recipe "db::do_restore"

ruby_block "wipe_existing_runtime_config" do
  block do
    Chef::Log.info "Wiping existing runtime config files"
    data_dir = ::File.join(node[:db][:data_dir], 'mysql')
    files_to_delete = [ "master.info","relay-log.info","mysql-bin.*","*relay-bin.*"]
    files_to_delete.each do |file|
      expand = Dir.glob(::File.join(data_dir,file))
      unless expand.empty?
	expand.each do |exp_file|
	  FileUtils.rm_rf(exp_file)
	end
      end
    end
  end
end

# disable binary logging
node[:db_mysql][:log_bin_enabled] = false

# we refactored setup_my_cnf into db::install_server, we might want to break that out again?
# Setup my.cnf
template_source = "my.cnf.erb"

template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
  source template_source
  owner "root"
  group "root"
  mode "0644"
  variables(
    :server_id => node[:db_mysql][:server_id]
  )
  cookbook 'db_mysql'
end

# empty out the binary log dir
directory ::File.dirname(node[:db_mysql][:log_bin]) do
  action [:delete, :create]
  recursive true
  owner 'mysql'
  group 'mysql'
end

# ensure_db_started
# service provider uses the status command to decide if it
# has to run the start command again.
10.times do
  service "mysql" do
    action :start
  end
end

# checks for valid backup and that current master matches backup
ruby_block "validate_backup" do
  block do
    master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)
    raise "Position and file not saved!" unless master_info['Master_instance_uuid']
    # Check that the snapshot is from the current master or a slave associated with the current master
    if master_info['Master_instance_uuid'] != node[:db_mysql][:current_master_uuid]
      raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_uuid']} != current master: #{node[:db_mysql][:current_master_uuid]}"
    end
  end
end

ruby_block "reconfigure_replication" do
  block do
    RightScale::Database::MySQL::Helper.reconfigure_replication(node)
  end
end

ruby_block "do_query" do
  block do
    RightScale::Database::MySQL::Helper.do_query(node, "SET GLOBAL READ_ONLY=1")
  end
end

node[:db_mysql][:tunable][:read_only] = 1
template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
  source template_source
  owner "root"
  group "root"
  mode "0644"
  variables(
    :server_id => node[:db_mysql][:server_id]
  )
  cookbook 'db_mysql'
end

include_recipe 'db_mysql::setup_slave_backup'

rs_utils_marker :end
