#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
set_unless[:db][:init_status] = :uninitialized  # Checks if DB has been initialezed
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
