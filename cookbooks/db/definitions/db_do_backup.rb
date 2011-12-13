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

  nickname = node[:block_device][:nickname]
  data_dir = node[:db][:data_dir]

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
  db data_dir do
    action :pre_backup_check
  end
  
  # == Aquire the backup lock or die
  #
  # This lock is released in the 'backup' script for now.
  # See below for more information about 'backup'
  # if 'force' is true, kills pid and removes locks
  #
  block_device nickname do
    action :backup_lock_take
    force do_force
  end
  
  log "  Performing (#{do_backup_type} backup) lock DB and write backup info file..."
  db data_dir do
    action [ :lock, :write_backup_info ]
  end
  
  log "  Performing (#{do_backup_type} backup)Snapshot with lineage #{node[:db][:backup][:lineage]}.."
  # Requires block_device node[:db][:block_device] to be instantiated
  # previously. Make sure block_device::default recipe has been run.
  block_device nickname do
    lineage node[:db][:backup][:lineage]
    action :snapshot
  end
  
  log "  Performing unlock DB..."
  db data_dir do
    action :unlock
  end
  
  log "  Performing (#{do_backup_type})Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."
  cloud node[:cloud][:provider]
  # Log that storage rotation is not supported on ROS storage types
  if ( cloud == "Rackspace" )
    log "  ROS storage type (Eg: Rackspace) does not support rotation.  Use of rotation inputs will be ignored."
  end

  secondary_storage_cloud = node[:block_device][:backup][:secondary][:cloud]
  secondary_storage_container = node[:block_device][:backup][:secondary][:container]
  # backup.rb removes the file lock created from :backup_lock_take
  log "  Forking background process to complete backup... (see /var/log/messages for results)"
  background_exe = ["/opt/rightscale/sandbox/bin/backup.rb",
                    "--backuponly",
                    "--lineage #{node[:db][:backup][:lineage]}",
                    "--nickname #{nickname}",
                    "--mount-point #{data_dir}",
                    "--cloud #{node[:cloud][:provider]}",
                    secondary_storage_cloud ? "--secondary_storage-cloud #{secondary_storage_cloud}":"",
                    secondary_storage_container ? "--secondary_storage-container #{secondary_storage_container}":"",
                    (node[:block_device][:rackspace_snet] == false)  ? "--no-snet" : "",
                    "--max-snapshots #{node[:block_device][:backup][:primary][:keep][:max_snapshots]}",
                    "--keep-daily #{node[:block_device][:backup][:primary][:keep][:keep_daily]}",
                    "--keep-weekly #{node[:block_device][:backup][:primary][:keep][:keep_weekly]}",
                    "--keep-monthly #{node[:block_device][:backup][:primary][:keep][:keep_monthly]}",
                    "--keep-yearly #{node[:block_device][:backup][:primary][:keep][:keep_yearly]}",
                    "2>&1 | logger -t rs_db_backup &"].join(" ")

  log "  background process = '#{background_exe}'"
  bash "backup.rb" do
    environment ({ 
                   "PRIMARY_STORAGE_KEY" => node[:block_device[:backup][:primary][:cred][:user],
                   "PRIMARY_STORAGE_SECRET" => node[:block_device[:backup][:primary][:cred][:user],
                   "SECONDARY_STORAGE_KEY" => node[:block_device[:backup][:secondary][:cred][:user],
                   "SECONDARY_STORAGE_SECRET" => node[:block_device[:backup][:secondary][:cred][:user]
                })


      'STORAGE_ACCOUNT_ID_RACKSPACE' => node[:block_device][:rackspace_user],
      'STORAGE_ACCOUNT_SECRET_RACKSPACE' => node[:block_device][:rackspace_secret],
      'STORAGE_ACCOUNT_ID_AWS' => node[:block_device][:aws_access_key_id],
      'STORAGE_ACCOUNT_SECRET_AWS' => node[:block_device][:aws_secret_access_key]
    })
    code background_exe
  end
end
