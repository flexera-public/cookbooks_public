# Cookbook Name:: app_tomcat
# Attributes:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set[:app][:provider] = "app_tomcat"
# == Recommended attributes
#
set_unless[:tomcat][:server_name] = "myserver"  
set_unless[:tomcat][:application_name] = "myapp"

set_unless[:tomcat][:java][:permsize] = "256m"
set_unless[:tomcat][:java][:maxpermsize] = "256m"
set_unless[:tomcat][:java][:newsize] = "256m"
set_unless[:tomcat][:java][:maxnewsize] = "256m"

# this docroot is currently symlinked from /usr/share/tomcat6/webapps
set[:tomcat][:docroot] = "/srv/tomcat6/webapps/#{node[:tomcat][:application_name]}"

# == Repo attributes
#
set_unless[:tomcat][:code][:url] = ""
set_unless[:tomcat][:code][:credentials] = ""
set_unless[:tomcat][:code][:svn_username] = ""
set_unless[:tomcat][:code][:svn_password] = ""

set_unless[:tomcat][:code][:provider_type] = ""
set_unless[:tomcat][:code][:ssh_key] = ""
set_unless[:tomcat][:code][:ros][:storage_account_provider] = ""
set_unless[:tomcat][:code][:ros][:storage_account_id] = ""
set_unless[:tomcat][:code][:ros][:storage_account_secret] = ""
set_unless[:tomcat][:code][:ros][:container] = ""
set_unless[:tomcat][:code][:ros][:prefix] = ""

set_unless[:tomcat][:code][:branch] = "HEAD"
set_unless[:tomcat][:db_adapter] = "mysql"
#TODo remove pull
if set_unless[:tomcat][:code][:perform_action] == "pull"
  set_unless[:tomcat][:code][:perform_action] = :pull
else
  set_unless[:tomcat][:code][:perform_action] = :capistrano_pull
end


# == Calculated attributes
#
case node[:platform]

  when "ubuntu", "debian"
  #tomcat6 tomcat6-admin tomcat6-common tomcat6-user
    set[:tomcat][:package_dependencies] = ["ecj-gcj",\
                                        # "java-gcj-compat-dev",\
                                         "tomcat6",\
                                         "tomcat6-admin",\
                                         "tomcat6-common",\
                                         "tomcat6-user",\
                                         "libmysql-java",\
                                         "libtcnative-1"
    ]
    set[:tomcat][:module_dependencies] = [ "proxy", "proxy_http" ]
    set_unless[:tomcat][:app_user] = "tomcat6"
    set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
    set[:tomcat][:alternatives_cmd] = "update-alternatives  --auto java"
  when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
    set[:tomcat][:package_dependencies] = ["eclipse-ecj",\
                                         "tomcat6",\
                                         "tomcat6-admin-webapps",\
                                         "tomcat6-webapps",\
                                         "tomcat-native",\
                                         "mysql-connector-java"]
    set[:tomcat][:module_dependencies] = [ "proxy", "proxy_http" ]
    set_unless[:tomcat][:app_user] = "tomcat"
    set[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
    set[:tomcat][:alternatives_cmd] = "alternatives --auto java"
end
