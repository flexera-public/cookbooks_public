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

# Intended for development and testing only
# Most of the time the server will get reset to an original state, but no garuntees
# If you really need a server in a garunteed state then (re)launch a new one.
#
rs_utils_marker :begin

raise "Force reset saftey not off.  Override block_device/force_reset_safety to run this recipe" unless node[:block_device][:force_reset_safety] == "off"

log "  Brute force tear down of the setup..... Hope it works :-)"
DATA_DIR = node[:db][:data_dir]

log "  Resetting the database..."
db DATA_DIR do
  action :reset
end

log "  Resetting block device..."
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :reset
end

log "  Remove tags..."
bash "remove tags" do
  code <<-EOH
  rs_tag -r 'rs_dbrepl:*'
  EOH
end

ruby_block "Reset db node state" do
  block do
    node[:db][:this_is_master] = false
    node[:db][:current_master_uuid] = nil
    node[:db][:current_master_ip] = nil
  end
end

log "  Resetting database, then starting database..."
db DATA_DIR do
  action [ :reset, :start ]
end

log "  Setting database state to 'uninitialized'..."
db_init_status :reset

log "  Cleaning cron..."
block_device DATA_DIR do
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  action :backup_schedule_disable
end

rs_utils_marker :end
