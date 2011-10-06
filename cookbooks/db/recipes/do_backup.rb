# Cookbook Name:: db
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

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
#
block_device DATA_DIR do
  action :backup_lock_take
end

log "  Performing lock DB and write backup info file..."
db DATA_DIR do
  action [ :lock, :write_backup_info ]
end

log "  Performing Snapshot with lineage #{node[:db][:backup][:lineage]}.."
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

log "  Performing Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."

if node[:cloud][:provider] == "rackspace"
  account_id = node[:block_device][:rackspace_user]
  account_secret = node[:block_device][:rackspace_secret]
else
  account_id = node[:block_device][:aws_access_key_id]
  account_secret = node[:block_device][:aws_secret_access_key]
end

log "  Forking background process to complete backup... (see /var/log/messages for results)"
bash "backup.rb" do
  environment ({ 
    'STORAGE_ACCOUNT_ID' => account_id,
    'STORAGE_ACCOUNT_SECRET' => account_secret
  })
  code <<-EOH
  /opt/rightscale/sandbox/bin/backup.rb --backuponly --lineage #{node[:db][:backup][:lineage]} --cloud #{node[:cloud][:provider]} --storage-type #{node[:block_device][:storage_type]} --container #{node[:block_device][:storage_container]} 2>&1 | logger -t rs_db_backup &
  EOH
end

rs_utils_marker :end
