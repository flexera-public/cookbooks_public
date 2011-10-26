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

set_unless[:db][:fqdn] = ""
set_unless[:db][:data_dir] = "/mnt/storage"
set_unless[:db][:provider] = "db_mysql"
set_unless[:db][:admin][:user] = "root"
set_unless[:db][:admin][:password] = ""

set_unless[:db][:replication][:user] = nil
set_unless[:db][:replication][:password] = nil

set_unless[:db][:backup][:lineage] = ""

#
# Server state variables
#
set_unless[:db][:db_restored] = false         # A restore operation was performed on this server
set_unless[:db][:db_initialized] = false      # Db is ready for use, specificially ready for backup
set_unless[:db][:this_is_master] = false
set_unless[:db][:current_master_uuid] = nil
set_unless[:db][:current_master_ip] = nil

#
# Calculate recommended backup times for master/slave
#
set_unless[:db][:backup][:master][:minute] = 5 + rand(54) # backup starts random time between 5-59
set_unless[:db][:backup][:master][:hour] = rand(23) # once a day, random hour

user_set = true if db[:backup][:slave] && db[:backup][:slave][:minute]
set_unless[:db][:backup][:slave][:minute] = 5 + rand(54) # backup starts random time between 5-59

if db[:backup][:slave][:minute] == db[:backup][:master][:minute]
  log_msg = "WARNING: detected master and slave backups collision."
  unless user_set
    db[:backup][:slave][:minute] = db[:backup][:slave][:minute].to_i / 2
    log_msg += "  Changing slave minute to avoid collision: #{db[:backup][:slave][:minute]}"
  end
  Chef::Log.info log_msg
end

set_unless[:db][:backup][:slave][:hour] = "*" # every hour
