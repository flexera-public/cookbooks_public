#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

node[:db_mysql][:version] ||= "5.1"
node[:db_mysql][:service_name] ||= "mysqld"
include_recipe "db::install_client"

rs_utils_marker :end
