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

db_find_master

include_recipe "db::request_master_allow"

include_recipe "db::do_primary_restore"

db DATA_DIR do
  action :enable_replication
end

db DATA_DIR do
  action :setup_monitoring
end

# Force a new backup
db_request_backup "do force backup" do
  force true
end

include_recipe "db::do_primary_backup_schedule_enable"

rs_utils_marker :end
