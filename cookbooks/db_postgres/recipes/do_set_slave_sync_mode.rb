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
# Set sync mode on master server
#
  log "Initializing slave to connect to master in sync state..."
  # updates postgresql.conf for replication
  Chef::Log.info "updates postgresql.conf for replication"
  RightScale::Database::PostgreSQL::Helper.configure_postgres_conf(node)

  # Reload postgresql to read new updated postgresql.conf
  Chef::Log.info "Reload postgresql to read new updated postgresql.conf"
  RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')

else
  raise "This is not master server! This script only runs on master: #{node[:db][:current_master_uuid]}"
end

rs_utils_marker :end
