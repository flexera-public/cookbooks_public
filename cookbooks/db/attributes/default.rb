#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:db][:dns][:master][:fqdn] = "localhost"
set_unless[:db][:data_dir] = "/mnt/storage"
set_unless[:db][:provider] = "db_mysql"
set_unless[:db][:admin][:user] = "root"
set_unless[:db][:admin][:password] = ""

set_unless[:db][:replication][:user] = nil
set_unless[:db][:replication][:password] = nil

set_unless[:db][:backup][:lineage] = ""
set_unless[:db][:backup][:lineage_override] = ""

set_unless[:db][:dns][:ttl] = "120"

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
#  Offset the start time by random number.  Skip the minutes near the exact hour and 1/2 hour.  This is done to prevent
#  overloading the API and cloud providers (such as amazon).  If every rightscale server sent a request at the same
#  time to perform a snapshot it would be a huge usage spike.  The random start time evens this spike out.
#  

# Generate random minute
#  Master and slave backup times are staggered by 30 minutes.
cron_min = 5 + rand(24)
# Master backup every 4 hours at a random minute between 5-29
set_unless[:db][:backup][:primary][:master][:cron][:hour] = "*/4"
set_unless[:db][:backup][:primary][:master][:cron][:minute] = cron_min

# Slave backup every hour at a random minute 30 minutes offset from the master.
set_unless[:db][:backup][:primary][:slave][:cron][:hour] = "*" # every hour
set_unless[:db][:backup][:primary][:slave][:cron][:minute] = cron_min + 30

set_unless[:db][:backup][:force] = 'false'
