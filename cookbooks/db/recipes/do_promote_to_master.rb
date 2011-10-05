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

# == Verify initalized database
# Check the node state to verify that we have correctly initialized this server.
#
db_state_assert :slave

# == Open port for slave replication by old-master
#
sys_firewall "Open port 3306 to the old master which is becoming a slave" do
  port 3306
  enable true
  ip_addr node[:db][:current_master_ip]
  action :update
end

# == Promote to master
# Do promote, but do not change master tags or node state yet.
#
include_recipe "db::setup_replication_privileges"

db node[:db][:data_dir] do
  action :promote
end

# == Schedule backups on slave
# This should be done before calling db::do_lookup_master 
# changes current_master from old to new. 
# 
remote_recipe "enable slave backups on oldmaster" do
  recipe "db::do_backup_schedule_enable"
  recipients_tags "rs_dbrepl:master_instance_uuid=#{node[:db][:current_master_uuid]}"
end

# == Demote old master
#
remote_recipe "demote master" do
  recipe "db::handle_demote_master"
  attributes :remote_recipe => {
                :new_master_ip => node[:cloud][:private_ips][0],
                :new_master_uuid => node[:rightscale][:instance_uuid]
              }
  recipients_tags "rs_dbrepl:master_instance_uuid=#{node[:db][:current_master_uuid]}"
end

# == Tag as master
# Changes master status tags and node state
#
include_recipe 'db::do_tag_as_master' 

# == Schedule master backups
#
include_recipe 'db::do_backup'
include_recipe "db::do_backup_schedule_enable"

rs_utils_marker :end
