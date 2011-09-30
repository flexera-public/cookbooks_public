# Cookbook Name:: db_mysql
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

set_unless[:db_mysql][:backup][:slave][:max_allowed_lag] = 60

