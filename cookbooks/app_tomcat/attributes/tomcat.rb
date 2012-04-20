#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
set_unless[:tomcat][:server_name] = node[:web_apache][:server_name]
set_unless[:tomcat][:application_name] = node[:web_apache][:application_name]
set_unless[:tomcat][:code][:root_war] = ""
set_unless[:tomcat][:java][:permsize] = "256m"
set_unless[:tomcat][:java][:maxpermsize] = "256m"
set_unless[:tomcat][:java][:newsize] = "256m"
set_unless[:tomcat][:java][:maxnewsize] = "256m"
set_unless[:tomcat][:db_adapter] = "mysql"

set[:tomcat][:module_dependencies] = [ "proxy", "proxy_http", "deflate", "rewrite"]

# This docroot is currently symlinked from /usr/share/tomcat6/webapps
set[:tomcat][:docroot] = "/srv/tomcat6/webapps/#{node[:tomcat][:application_name]}"

# Calculated attributes
case node[:platform]
when "ubuntu", "debian"
  set[:tomcat][:app_user] = "tomcat6"
  set[:tomcat][:alternatives_cmd] = "update-alternatives  --auto java"
  if(tomcat[:db_adapter] == "mysql")
    set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  elsif(tomcat[:db_adapter] == "postgresql")
    set[:db_postgres][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:tomcat][:db_adapter]}, exiting "
  end
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  set[:tomcat][:app_user] = "tomcat"
  set[:tomcat][:alternatives_cmd] = "alternatives --auto java"
  if(tomcat[:db_adapter] == "mysql")
    set[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
  elsif(tomcat[:db_adapter] == "postgresql")
    set[:db_postgres][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:tomcat][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end
