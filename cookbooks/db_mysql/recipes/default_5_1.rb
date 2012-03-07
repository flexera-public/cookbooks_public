#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

version="5.1"
node[:db][:provider] = "db_mysql"

log "Setting DB MySQL version to #{version}"

# Set MySQL 5.1 specific node variables in this recipe.
#
node[:db_mysql][:version] = version
node[:db_mysql][:service_name] = "mysql"

platform = node[:platform]
case platform
when "redhat","centos","fedora","suse"
  node[:db_mysql][:packages_uninstall] = ""
  node[:db_mysql][:client_packages_install] = ["MySQL-shared-compat",
                                               "MySQL-devel-community",
                                               "MySQL-client-community" ]
  node[:db_mysql][:server_packages_install] = ["MySQL-server-community"]
when "debian","ubuntu"
  node[:db_mysql][:packages_uninstall] = ""
  node[:db_mysql][:client_packages_install] = ["libmysqlclient-dev", "mysql-client-5.1"]
  node[:db_mysql][:server_packages_install] = ["mysql-server-5.1"]
else
  raise "Unsupported platform #{platform} for MySQL Version #{version}"
end

rs_utils_marker :end
