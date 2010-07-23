# Cookbook Name:: db_mysql
#
# Copyright (c) 2009 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#
# Required attributes
#
set_unless[:db_mysql][:admin_user] = nil
set_unless[:db_mysql][:admin_password] = nil
set_unless[:db_mysql][:server_id] = Time.now.to_i

#
# Recommended attributes
#
set_unless[:db_mysql][:server_usage] = "dedicated"  # or "shared"

#
# Optional attributes
#
set_unless[:db_mysql][:datadir_relocate] = "/mnt/mysql"
set_unless[:db_mysql][:log_bin_enabled] = true
set_unless[:db_mysql][:log_bin] = "/mnt/mysql-binlogs/mysql-bin"
set_unless[:db_mysql][:tmpdir] = "/tmp"
set_unless[:db_mysql][:datadir] = "/var/lib/mysql"
set_unless[:db_mysql][:bind_address] = ipaddress

#
# Platform specific attributes

set_unless[:db_mysql][:kill_bug_mysqld_safe] = true

case platform
when "redhat","centos","fedora","suse"
	set_unless[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
  set_unless[:db_mysql][:basedir] = "/usr"
  set_unless[:db_mysql][:packages_uninstall] = ""
  set_unless[:db_mysql][:packages_install] = [
    "perl-DBD-MySQL", "mysql-server", "mysql-devel", "mysql-connector-odbc", 
#    not available on CentOS 5.4?
#    "mysqlclient14-devel", "mysqlclient14", "mysqlclient10-devel", "mysqlclient10", 
    "krb5-libs"
	]
  set_unless[:db_mysql][:log] = ""
  set_unless[:db_mysql][:log_error] = "" 
when "debian","ubuntu"
  set_unless[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  set_unless[:db_mysql][:basedir] = "/usr"
  set_unless[:db_mysql][:packages_uninstall] = "apparmor"
  if platform_version >= "10.04"
    set_unless[:db_mysql][:packages_install] = ["mysql-server-5.1", "tofrodos"]
  else 
    set_unless[:db_mysql][:packages_install] = ["mysql-server-5.0", "tofrodos"]
  end
  set_unless[:db_mysql][:log] = "log = /var/log/mysql.log"
  set_unless[:db_mysql][:log_error] = "log_error = /var/log/mysql.err" 
else
  set_unless[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  set_unless[:db_mysql][:basedir] = "/usr"
  set_unless[:db_mysql][:packages_uninstall] = ""
  set_unless[:db_mysql][:packages_install] = ["mysql-server-5.0"]
  set_unless[:db_mysql][:log] = "log = /var/log/mysql.log"
  set_unless[:db_mysql][:log_error] = "log_error = /var/log/mysql.err"
end
