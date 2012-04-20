#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

DATA_DIR = node[:db][:data_dir]
NICKNAME = get_device_or_default(node, :device1, :nickname)

log "  Verify if database state is 'uninitialized'..."
db_init_status :check do
  expected_state :uninitialized
  error_message "Database already initialized.  To over write existing database run do_force_reset before this recipe"
end

log "  Stopping database..."
db DATA_DIR do
  action :stop
end

log "  Creating block device..."
block_device NICKNAME do
  lineage node[:db][:backup][:lineage]
  action :create
end

log "  Moving database to block device and starting database..."
db DATA_DIR do
  action [ :move_data_dir, :start ]
end

log "  Setting state of database to be 'initialized'..."
db_init_status :set

log "  Registering as master..."
db_register_master

log "  Setting up monitoring for master..."
db DATA_DIR do
  action :setup_monitoring
end

log "  Adding replication privileges for this master database..."
include_recipe "db::setup_replication_privileges"

log "  Forcing a backup so slaves can init from this master..."
db_request_backup "do force backup" do
  force true
end

log "  Setting up cron to do scheduled backups..."
include_recipe "db::do_primary_backup_schedule_enable"

rs_utils_marker :end
