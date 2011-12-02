#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Recommended attributes
#
set_unless[:php][:application_name] = "myapp"

# == Optional attributes
#
set_unless[:php][:db_schema_name] = ""     

set_unless[:php][:code][:url] = ""
set_unless[:php][:code][:credentials] = ""
set_unless[:php][:code][:branch] = "master"  
set_unless[:php][:modules_list] = [] 
set_unless[:php][:db_adapter] = "mysql"

# == Calculated attributes
#
#set[:php][:code][:destination] = "/home/webapp/#{php[:application_name]}"

case platform
when "ubuntu", "debian"
  set[:php][:package_dependencies] = ["php5", "php5-mysql", "php-pear", "libapache2-mod-php5"] 
  set[:php][:module_dependencies] = [ "proxy_http", "php5"]
  set_unless[:php][:app_user] = "www-data"
  set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
when "centos","fedora","suse","redhat"
  set[:php][:package_dependencies] = ["php53u", "php53u-mysql", "php53u-pear", "php53u-zts"]
  set[:php][:module_dependencies] = [ "proxy", "proxy_http" ]
  set_unless[:php][:app_user] = "apache"
  set[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
end

