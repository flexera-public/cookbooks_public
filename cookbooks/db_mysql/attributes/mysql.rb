#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Required attributes
#
set_unless[:db_mysql][:version] = '5.5'


# Recommended attributes
#
set_unless[:db_mysql][:collectd_master_slave_mode] = ""
set_unless[:db_mysql][:previous_master] = nil


# Optional attributes
#
set_unless[:db_mysql][:port] = "3306"
set_unless[:db_mysql][:log_bin_enabled] = true
set_unless[:db_mysql][:log_bin] = "/mnt/ephemeral/mysql-binlogs/mysql-bin"
set_unless[:db_mysql][:tmpdir] = "/mnt/ephemeral/tmp"
set_unless[:db_mysql][:datadir] = "/var/lib/mysql"
set_unless[:db_mysql][:datadir_relocate] = "/mnt/storage"
# Always set to support stop/start
set[:db_mysql][:bind_address] = cloud[:private_ips][0]

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
  set_unless[:db_mysql][:log] = ""
  set_unless[:db_mysql][:log_error] = "" 
when "debian","ubuntu"
  set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  set_unless[:db_mysql][:log] = "log = /var/log/mysql.log"
  set_unless[:db_mysql][:log_error] = "log_error = /var/log/mysql.err" 
else
  raise "Unsupported platform #{platform}"
end

# System tuning parameters
# Set the mysql and root users max open files to a really large number.
# 1/3 of the overall system file max should be large enough.  The percentage can be
# adjusted if necessary.
set_unless[:db_mysql][:file_ulimit] = `sysctl -n fs.file-max`.to_i/33
