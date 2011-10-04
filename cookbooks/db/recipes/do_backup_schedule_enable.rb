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

snap_lineage = node[:db][:backup][:lineage]
raise "ERROR: 'Backup Lineage' required for scheduled process" if snap_lineage.empty?

# TODO: fix for LAMP
if node[:db][:this_is_master]
  hour = node[:db][:backup][:master][:hour]
  minute = node[:db][:backup][:master][:minute]
else
  hour = node[:db][:backup][:slave][:hour]
  minute = node[:db][:backup][:slave][:minute]
end

block_device DATA_DIR do
  lineage snap_lineage
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  cron_backup_hour hour.to_s
  cron_backup_minute minute.to_s
  action :backup_schedule_enable
end

rs_utils_marker :end
