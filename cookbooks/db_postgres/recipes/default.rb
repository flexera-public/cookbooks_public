#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Setup default values for database resource
#
rs_utils_marker :begin

node[:db][:provider] = "db_postgres"
version="#{node[:db_postgres][:version]}"

log "Setting DB provider to #{node[:db][:provider]} and PostgreSQL version to #{version}"

db node[:db][:data_dir] do
  persist true
  provider node[:db][:provider]
  action :nothing
end

platform = node[:platform]
case platform
when "centos"
  node[:db_postgres][:client_packages_install] = ["postgresql91-libs", "postgresql91", "postgresql91-devel" ] 
  node[:db_postgres][:server_packages_install] = ["postgresql91-libs", "postgresql91", "postgresql91-devel", "postgresql91-server", "postgresql91-contrib" ]
else
  raise "Unsupported platform #{platform} for PostgreSQL Version #{version}"
end

rs_utils_marker :end
