#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Request postgresql.conf updated
#
rs_utils_marker :begin

raise "Skipping to postgresql update slave sync mode on master server, not selected any valid input enable/disable" if node[:db_postgres][:slave][:sync] == ""

to_enable = (node[:db_postgres][:slave][:sync] == "enable") ? true : false

if node[:db_postgres][:slave][:sync] == "enable"
  log "Initializing slave to connect to master in sync state..."
  # updates postgresql.conf for replication
  Chef::Log.info "updates postgresql.conf for replication"
  RightScale::Database::PostgreSQL::Helper.configure_postgres_conf(node)

  # Reload postgresql to read new updated postgresql.conf
  Chef::Log.info "Reload postgresql to read new updated postgresql.conf"
  RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')

elsif node[:db_postgres][:slave][:sync] == "disable"
  # Disable sync state
  # Setup postgresql.conf
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
  log "WARNING: Skipping to postgresql update slave sync mode on master server, not selected any valid user input enable/disable" do
    level :warn
  end

end

rs_utils_marker :end
