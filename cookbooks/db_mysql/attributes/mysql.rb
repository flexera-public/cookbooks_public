#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#
set_unless[:db_mysql][:server_usage] = "dedicated"  # or "shared"
set_unless[:db_mysql][:previous_master] = nil


# Optional attributes
#
set_unless[:db_mysql][:port] = "3306"
set_unless[:db_mysql][:log_bin_enabled] = true
set_unless[:db_mysql][:log_bin] = "/mnt/mysql-binlogs/mysql-bin"
set_unless[:db_mysql][:tmpdir] = "/tmp"
set_unless[:db_mysql][:datadir] = "/var/lib/mysql"
set_unless[:db_mysql][:datadir_relocate] = "/mnt/storage"
set_unless[:db_mysql][:bind_address] = cloud[:private_ips][0]

set_unless[:db_mysql][:dump][:schema_name] = ""
set_unless[:db_mysql][:dump][:storage_account_provider] = ""
set_unless[:db_mysql][:dump][:storage_account_id] = ""
set_unless[:db_mysql][:dump][:storage_account_secret] = ""
set_unless[:db_mysql][:dump][:container] = ""
set_unless[:db_mysql][:dump][:prefix] = ""

# Platform specific attributes
#
set_unless[:db_mysql][:kill_bug_mysqld_safe] = true

case platform
when "redhat","centos","fedora","suse"
	set[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
  set_unless[:db_mysql][:basedir] = "/var/lib"
  set_unless[:db_mysql][:log] = ""
  set_unless[:db_mysql][:log_error] = "" 
when "debian","ubuntu"
  set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  set_unless[:db_mysql][:basedir] = "/usr"
  set_unless[:db_mysql][:log] = "log = /var/log/mysql.log"
  set_unless[:db_mysql][:log_error] = "log_error = /var/log/mysql.err" 
else
  raise "Unsupported platform #{platform} for MySQL Version #{version}"
end

# == Version specific packages
#
case node[:db_mysql][:version]
when "5.1"
  case platform
  when "redhat","centos","fedora","suse"
    set_unless[:db_mysql][:packages_uninstall] = ""
    set_unless[:db_mysql][:client_packages_install] = ["MySQL-shared-compat",
                                                       "MySQL-devel-community",
                                                       "MySQL-client-community" ]
    set_unless[:db_mysql][:server_packages_install] = ["MySQL-server-community"]
  when "debian","ubuntu"
#    set_unless[:db_mysql][:packages_uninstall] = ["apparmor"]
    set_unless[:db_mysql][:packages_uninstall] = ""
    set_unless[:db_mysql][:client_packages_install] = ["libmysqlclient-dev", "mysql-client-5.1"]
    set_unless[:db_mysql][:server_packages_install] = ["mysql-server-5.1"]
  else
    raise "Unsupported platform #{platform} for MySQL Version #{version}"
  end
when "5.5"
  case platform
  when "redhat","centos","fedora","suse"
  # http://dev.mysql.com/doc/refman/5.5/en/linux-installation-native.html
  # For Red Hat and similar distributions, the MySQL distribution is divided into a 
  # number of separate packages, mysql for the client tools, mysql-server for the 
  # server and associated tools, and mysql-libs for the libraries. 
    set_unless[:db_mysql][:packages_uninstall] = ""
    set_unless[:db_mysql][:client_packages_install] = ["mysql55-devel", "mysql55-libs", "mysql55"]
    set_unless[:db_mysql][:server_packages_install] = ["mysql55-server"]
  else
    raise "Unsupported platform #{platform} for MySQL Version #{version}"
  end
else
  raise "Unsupported MySQL Version #{version}"
end

