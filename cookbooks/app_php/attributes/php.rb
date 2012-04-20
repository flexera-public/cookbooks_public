#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Optional attributes
set_unless[:php][:db_schema_name] = ""
set_unless[:php][:modules_list] = []
set_unless[:php][:db_adapter] = "mysql"

# Calculated attributes
case platform
when "ubuntu", "debian"
  set[:php][:module_dependencies] = [ "proxy_http", "php5"]
  set_unless[:php][:app_user] = "www-data"
  if(php[:db_adapter] == "mysql")
    set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  elsif(php[:db_adapter] == "postgresql")
    set[:db_postgres][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting "
  end
when "centos","fedora","suse","redhat"
  set[:php][:module_dependencies] = [ "proxy", "proxy_http" ]
  set_unless[:php][:app_user] = "apache"
  if(php[:db_adapter] == "mysql")
    set[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
  elsif(php[:db_adapter] == "postgresql")
    set[:db_postgres][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:php][:db_adapter]}, exiting "
  end
end
