#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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

  class Chef::Resource::Bash
    include RightScale::BlockDeviceHelper
  end

  NICKNAME = get_device_or_default(node, :device1, :nickname)
  DATA_DIR = node[:db][:data_dir]

  do_force        = params[:force] == true ? true : false
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

  log "  Performing (#{do_backup_type} backup)Snapshot with lineage #{node[:db][:backup][:lineage]}.."
  # Requires block_device node[:db][:block_device] to be instantiated
  # previously. Make sure block_device::default recipe has been run.
  block_device NICKNAME do
    lineage node[:db][:backup][:lineage]
    action :snapshot
  end

  log "  Performing unlock DB..."
  db DATA_DIR do
    action :unlock
  end

  log "  Performing (#{do_backup_type})Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."
  cloud = node[:cloud][:provider]
  # Log that storage rotation is not supported on ROS storage types
  if ( cloud == "Rackspace" )
    log "  ROS storage type (Eg: Rackspace) does not support rotation.  Use of rotation inputs will be ignored."
  end

  # If doing a secondary backup, set variables needed for this.
  if do_backup_type == "secondary"
    secondary_storage_cloud = get_device_or_default(node, :device1, :backup, :secondary, :cloud)
    if secondary_storage_cloud =~ /aws/i
      secondary_storage_cloud = "s3"
    elsif secondary_storage_cloud =~ /rackspace/i
      secondary_storage_cloud = "cloudfiles"
    end
    secondary_storage_container = get_device_or_default(node, :device1, :backup, :secondary, :container)
  elsif do_backup_type == 'primary'
    primary_storage_cloud = get_device_or_default(node, :device1, :backup, :primary, :cloud)
  end

  # backup.rb removes the file lock created from :backup_lock_take
  log "  Forking background process to complete backup... (see /var/log/messages for results)"
  max_snapshots = get_device_or_default(node, :device1, :backup, :primary, :keep, :max_snapshots)
  keep_daily    = get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_daily)
  keep_weekly   = get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_weekly)
  keep_monthly  = get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_monthly)
  keep_yearly   = get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_yearly)
  background_exe = [
    "/opt/rightscale/sandbox/bin/backup",
    "--backuponly",
    "--lineage #{node[:db][:backup][:lineage]}",
    "--nickname #{NICKNAME}",
    "--mount-point #{DATA_DIR}",
    "--cloud #{cloud}",
    "--backup-type #{do_backup_type}",
    primary_storage_cloud && do_backup_type == 'primary' ? "--primary-storage-cloud #{primary_storage_cloud}" : '',
    secondary_storage_cloud && do_backup_type == 'secondary' ? "--secondary-storage-cloud #{secondary_storage_cloud}" : '',
    secondary_storage_container && do_backup_type == 'secondary' ? "--secondary-storage-container #{secondary_storage_container}" : '',
    (get_device_or_default(node, :device1, :rackspace_snet) == false) ? '--no-snet' : '',
    max_snapshots ? "--max-snapshots #{max_snapshots}" : '',
    keep_daily    ? "--keep-daily #{keep_daily}"       : '',
    keep_weekly   ? "--keep-weekly #{keep_weekly}"     : '',
    keep_monthly  ? "--keep-monthly #{keep_monthly}"   : '',
    keep_yearly   ? "--keep-yearly #{keep_yearly}"     : '',
    "2>&1 | logger -t rs_db_backup &"
  ].join(" ")

  log "  background process = '#{background_exe}'"
  bash "backup.rb" do
    flags "-ex"
    environment ({ 
      'PRIMARY_STORAGE_KEY'      => get_device_or_default(node, :device1, :backup, :primary, :cred, :user),
      'PRIMARY_STORAGE_SECRET'   => get_device_or_default(node, :device1, :backup, :primary, :cred, :secret),
      'SECONDARY_STORAGE_KEY'    => get_device_or_default(node, :device1, :backup, :secondary, :cred, :user),
      'SECONDARY_STORAGE_SECRET' => get_device_or_default(node, :device1, :backup, :secondary, :cred, :secret)
    })
    code background_exe
  end
end
