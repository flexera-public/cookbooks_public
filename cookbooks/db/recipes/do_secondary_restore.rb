#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]
NICKNAME = node[:block_device][:nickname]

db_init_status :check do
  expected_state :uninitialized
  error_message "Database already restored.  To over write existing database run do_force_reset before this recipe"
end

log "  Running pre-restore checks..."
db DATA_DIR do
  action :pre_restore_check
end

if node[:db][:backup][:lineage_override].empty?
  backup_lineage = node[:db][:backup][:lineage]
else
  log "** USING LINEAGE OVERRIDE **"
  backup_lineage = node[:db][:backup][:lineage_override]
end

log "======== LINEAGE ========="
log backup_lineage
log "======== LINEAGE ========="

log "  Stopping database..."
db DATA_DIR do
  action :stop
end

secondary_storage_cloud = node[:block_device][:backup][:secondary][:cloud]
if secondary_storage_cloud =~ /aws/i
  secondary_storage_cloud = "s3"
elsif secondary_storage_cloud =~ /rackspace/i
  secondary_storage_cloud = "cloudfiles"
end

log "  Performing Secondary Restore from #{node[:db][:backup][:secondary_location]}..."
# Requires block_device DATA_DIR to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device NICKNAME do
  lineage node[:db][:backup][:lineage]
  lineage_override node[:db][:backup][:lineage_override]
  timestamp_override node[:db][:backup][:timestamp_override]

  volume_size node[:block_device][:volume_size]

  secondary_cloud secondary_storage_cloud
  secondary_container node[:block_device][:backup][:secondary][:container]
  secondary_user node[:block_device][:backup][:secondary][:cred][:user]
  secondary_secret node[:block_device][:backup][:secondary][:cred][:secret]

  action :secondary_restore
end

log "  Setting state of database to be 'initialized'..."
db_init_status :set

log "  Running post-restore cleanup..."
db DATA_DIR do
  action :post_restore_cleanup
end

log "  Starting database..."
db DATA_DIR do
  action [ :start, :status ]
end

rs_utils_marker :end
