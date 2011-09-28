# Cookbook Name:: db_mysql
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

set_unless[:db_mysql][:backup][:slave][:max_allowed_lag] = 60

set_unless[:db_mysql][:this_is_master] = false
set_unless[:db_mysql][:current_master_uuid] = nil
set_unless[:db_mysql][:current_master_ip] = nil
