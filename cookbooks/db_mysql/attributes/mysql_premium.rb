# Cookbook Name:: db_mysql
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

#set_unless[:db_mysql][:replication][:user] = nil
#set_unless[:db_mysql][:replication][:password] = nil

set_unless[:db_mysql][:backup][:slave][:max_allowed_lag] = 60


set_unless[:db_mysql][:this_is_master] = false
set_unless[:db_mysql][:current_master_uuid] = nil
set_unless[:db_mysql][:current_master_ip] = nil

# Calculate recommended backup times for master/slave

set_unless[:db_mysql][:backup][:master][:minute] = 5 + rand(54) # backup starts random time between 5-59
set_unless[:db_mysql][:backup][:master][:hour] = rand(23) # once a day, random hour

user_set = true if db_mysql[:backup][:slave] && db_mysql[:backup][:slave][:minute]
set_unless[:db_mysql][:backup][:slave][:minute] = 5 + rand(54) # backup starts random time between 5-59

if db_mysql[:backup][:slave][:minute] == db_mysql[:backup][:master][:minute]
  log_msg = "WARNING: detected master and slave backups collision."
  unless user_set
    db_mysql[:backup][:slave][:minute] = db_mysql[:backup][:slave][:minute].to_i / 2
    log_msg += "  Changing slave minute to avoid collision: #{db_mysql[:backup][:slave][:minute]}"
  end
  Chef::Log.info log_msg
end

set_unless[:db_mysql][:backup][:slave][:hour] = "*" # every hour
