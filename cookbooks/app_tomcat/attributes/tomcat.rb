# Cookbook Name:: app_tomcat
# Attributes:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Recommended attributes
#
set_unless[:tomcat][:server_name] = "myserver"  
set_unless[:tomcat][:application_name] = "myapp"

set_unless[:tomcat][:java][:permsize] = "256m"
set_unless[:tomcat][:java][:maxpermsize] = "256m"
set_unless[:tomcat][:java][:newsize] = "256m"
set_unless[:tomcat][:java][:maxnewsize] = "256m"

# == Optional attributes
#
set_unless[:tomcat][:code][:repo_type] = "git"
set_unless[:tomcat][:code][:url] = ""
set_unless[:tomcat][:code][:credentials] = ""
set_unless[:tomcat][:code][:svn_username] = ""
set_unless[:tomcat][:code][:svn_password] = ""

set_unless[:tomcat][:code][:branch] = "master"
set_unless[:tomcat][:db_adapter] = "mysql"

# this docroot is currently symlinked from /usr/share/tomcat6/webapps
set[:tomcat][:docroot] = "/srv/tomcat6/webapps"

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
