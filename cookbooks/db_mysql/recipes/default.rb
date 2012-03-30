#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

version = node[:db_mysql][:version]

case version
when '5.1', '5.5'
  include_recipe "db_mysql::default_#{version.gsub('.', '_')}"
else
  raise "Unsupported MySQL version: #{version}"
end

rs_utils_marker :end
