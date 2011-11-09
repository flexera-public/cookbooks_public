# Cookbook Name:: db
#
# Copyright (c) 2011 RightScale, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

  DATA_DIR = node[:db][:data_dir]

  do_force        = params[:force] == true ? true : false
  do_backup_type  = params[:backup_type] == "primary" ? "primary" : "secondary"

  # == Check if database is able to be backed up (initialized)
  # must be done in ruby block to expand node during converge not compile
  Chef::Log.info "Checking db_init_status making sure db ready for backup"
  db_init_status :check do
    expected_state :initialized
    error_message "Database not initialized."
  end

  # == Verify initalized database
  # Check the node state to verify that we have correctly initialized this server.
  db_state_assert :either
  
  log "  Performing pre-backup check..." 
  db DATA_DIR do
    action [ :pre_backup_check ]
  end
  
  # == Aquire the backup lock or die
  #
  # This lock is released in the 'backup.rb' script for now.
  # See below for more information about 'backup.rb'
  # if 'force' is true, kills pid and removes locks
  #
  block_device DATA_DIR do
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
  block_device DATA_DIR do
    lineage node[:db][:backup][:lineage]
    action :snapshot
  end
  
  log "  Performing unlock DB..."
  db DATA_DIR do
    action :unlock
  end
  
  log "  Performing (#{do_backup_type})Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."

  # Determine if doing primary or secondary backup and obtain correct cloud to store the backup.
  if ( do_backup_type == "primary")
    storage_cloud = nil
    storage_container = node[:block_device][:storage_container]
    storage_type      = node[:block_device][:storage_type]
  elsif ( do_backup_type == "secondary")
    storage_cloud = node[:db][:backup][:secondary_location].downcase
    storage_container = node[:db][:backup][:secondary_container]
    storage_type      = "ros"
  end

  log "  Forking background process to complete backup... (see /var/log/messages for results)"
  # backup.rb removes the file lock created from :backup_lock_take
  bash "backup.rb" do
    environment ({ 
      'STORAGE_ACCOUNT_ID_RACKSPACE' => node[:block_device][:rackspace_user],
      'STORAGE_ACCOUNT_SECRET_RACKSPACE' => node[:block_device][:rackspace_secret],
      'STORAGE_ACCOUNT_ID_AWS' => node[:block_device][:aws_access_key_id],
      'STORAGE_ACCOUNT_SECRET_AWS' => node[:block_device][:aws_secret_access_key]
    })
    code <<-EOH
    /opt/rightscale/sandbox/bin/backup.rb --backuponly --lineage #{node[:db][:backup][:lineage]} --cloud #{node[:cloud][:provider]} #{storage_cloud ? '--storage-cloud ' + storage_cloud : ''} --storage-type #{storage_type} #{node[:block_device][:rackspace_snet] ? '' : '--no-snet'} --container #{storage_container} 2>&1 | logger -t rs_db_backup &
    EOH
  end

end

