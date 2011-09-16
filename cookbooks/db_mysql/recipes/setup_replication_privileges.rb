#
# Cookbook Name:: db_mysql
# Recipe:: setup_replication_privileges
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

db "grant replication privileges" do
  action :grant_replication_slave
end

rs_utils_marker :end
