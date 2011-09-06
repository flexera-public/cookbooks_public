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
CLOUD = (node[:db][:backup][:secondary_location] == "CloudFiles") ? "rackspace" : "ec2" 

log "  Performing pre-backup check, then lock DB..."
db DATA_DIR do
  action [ :pre_backup_check, :lock ]
end

log "  Performing Snapshot..."
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

log "  Performing Backup..."
# Requires block_device DATA_DIR to be instantiated
# previously. Make sure block_device::default recipe has been run.
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  provider "block_device_ros"
  storage_container node[:db][:backup][:secondary_container]
  cloud CLOUD
  persist false
  action :backup
end

log "  Performing post-backup cleanup..."
db DATA_DIR do
  action :post_backup_cleanup
end

rs_utils_marker :end