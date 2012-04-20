#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_request_backup, :force => false, :backup_type => 'primary' do
  do_force        = params[:force]
  do_backup_type  = params[:backup_type] == "primary" ? "primary" : "secondary"

  remote_recipe "Request #{do_backup_type} backup" do
    recipe "db::do_#{do_backup_type}_backup"
    attributes :db => {:backup => {:force => "#{do_force}"}}
    recipients_tags "server:uuid=#{node[:rightscale][:instance_uuid]}"
  end
end

# == Does a snapshot backup of the filesystem containing the database
# Note that the upload becomes a background job in order to allow other recipes to
# not wait if the upload takes a long time.
# Since this backup is a snapshot of a filesystem, it will check if the database has
# been 'initialized', else it will fail.
# == Params
# force(Boolean):: If false, if a backup is currently running, will error out stating so.
#   If true, if a backup is currently running, will kill that process and take over the lock.
# backup_type(String):: If 'primary' will do a primary backup using node attributes specific
#   to the main backup.  If 'secondary' will do a secondary backup using node attributes for
#   secondary.  Secondary uses 'ROS'.
# == Exceptions
# If force is false and a backup is currently running, will raise an exception.
# If database is not 'initialized', will raise.
define :db_do_backup, :force => false, :backup_type => "primary" do

  class Chef::Recipe
    include RightScale::BlockDeviceHelper
  end

  class Chef::Resource::BlockDevice
    include RightScale::BlockDeviceHelper
  end

  NICKNAME = get_device_or_default(node, :device1, :nickname)
  DATA_DIR = node[:db][:data_dir]

  do_force        = params[:force]
  do_backup_type  = params[:backup_type] == "primary" ? "primary" : "secondary"

  # == Check if database is able to be backed up (initialized)
  # must be done in ruby block to expand node during converge not compile
  log "  Checking db_init_status making sure db ready for backup"
  db_init_status :check do
    expected_state :initialized
    error_message "Database not initialized."
  end

  # == Verify initalized database
  # Check the node state to verify that we have correctly initialized this server.
  db_state_assert :either

  log "  Performing pre-backup check..."
  db DATA_DIR do
    action :pre_backup_check
  end

  # == Aquire the backup lock or die
  #
  # This lock is released in the 'backup' script for now.
  # See below for more information about 'backup'
  # if 'force' is true, kills pid and removes locks
  #
  block_device NICKNAME do
    action :backup_lock_take
    force do_force
  end

  log "  Performing (#{do_backup_type} backup) lock DB and write backup info file..."
  db DATA_DIR do
    action [ :lock, :write_backup_info ]
  end

  log "  Performing (#{do_backup_type} backup) Snapshot with lineage #{node[:db][:backup][:lineage]}.."
  # Requires block_device node[:db][:block_device] to be instantiated
  # previously. Make sure block_device::default recipe has been run.
  block_device NICKNAME do
    action :snapshot
  end

  log "  Performing unlock DB..."
  db DATA_DIR do
    action :unlock
  end

  log "  Performing (#{do_backup_type}) Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."
  block_device NICKNAME do
    # Backup/Restore arguments
    lineage node[:db][:backup][:lineage]
    max_snapshots get_device_or_default(node, :device1, :backup, :primary, :keep, :max_snapshots)
    keep_daily get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_daily)
    keep_weekly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_weekly)
    keep_monthly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_monthly)
    keep_yearly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_yearly)

    # Secondary arguments
    secondary_cloud get_device_or_default(node, :device1, :backup, :secondary, :cloud)
    secondary_endpoint get_device_or_default(node, :device1, :backup, :secondary, :endpoint)
    secondary_container get_device_or_default(node, :device1, :backup, :secondary, :container)
    secondary_user get_device_or_default(node, :device1, :backup, :secondary, :cred, :user)
    secondary_secret get_device_or_default(node, :device1, :backup, :secondary, :cred, :secret)

    action do_backup_type == 'primary' ? :primary_backup : :secondary_backup
  end

  log "  Performing post backup cleanup..."
  db DATA_DIR do
    action :post_backup_cleanup
  end

  block_device NICKNAME do
    action :backup_lock_give
  end
end
