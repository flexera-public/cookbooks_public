# Cookbook Name:: db_mysql
#
# Copyright (c) 2011 RightScale Inc
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
  set_unless[:db_mysql][:packages_uninstall] = ""
  set_unless[:db_mysql][:packages_install] = ["MySQL-server-community", "MySQL-shared-compat", "MySQL-devel-community", "MySQL-client-community" ]
 # set_unless[:db_mysql][:packages_install] = [ "unixODBC.#{kernel[:machine] }", "krb5-libs" ]
  set_unless[:db_mysql][:log] = ""
  set_unless[:db_mysql][:log_error] = "" 
when "debian","ubuntu"
  set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  set_unless[:db_mysql][:basedir] = "/usr"
  set_unless[:db_mysql][:packages_uninstall] = "apparmor"
  if(platform_version == "10.10" || platform_version == "10.04")
    set_unless[:db_mysql][:packages_install] = ["mysql-server-5.1", "tofrodos"]
  else
    set_unless[:db_mysql][:packages_install] = ["mysql-server-5.0", "tofrodos"]
  end
  set_unless[:db_mysql][:log] = "log = /var/log/mysql.log"
  set_unless[:db_mysql][:log_error] = "log_error = /var/log/mysql.err" 
else
  set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  set_unless[:db_mysql][:basedir] = "/usr"
  set_unless[:db_mysql][:packages_uninstall] = ""
  set_unless[:db_mysql][:packages_install] = ["mysql-server-5.0"]
  set_unless[:db_mysql][:log] = "log = /var/log/mysql.log"
  set_unless[:db_mysql][:log_error] = "log_error = /var/log/mysql.err"
end

