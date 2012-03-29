#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Run only on master server
if node[:rightscale][:instance_uuid] == "#{node[:db][:current_master_uuid]}"
#
# Set async mode on master server
#
  # Enable async state
  # Setup postgresql.conf
  log "Initializing slave to connect to master in async state..."
  # updates postgresql.conf for replication
  Chef::Log.info "updates postgresql.conf for replication"
  template "#{node[:db_postgres][:confdir]}/postgresql.conf" do
    source "postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook 'db_postgres'
  end

  # Setup pg_hba.conf
  cookbook_file ::File.join(node[:db_postgres][:confdir], 'pg_hba.conf') do
    source "pg_hba.conf"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook 'db_postgres'
  end

  # Reload postgresql to read new updated postgresql.conf
  Chef::Log.info "Reload postgresql to read new updated postgresql.conf"
  RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')

else
  raise "This is not master server! This script only runs on master: #{node[:db][:current_master_uuid]}"
end

rs_utils_marker :end
