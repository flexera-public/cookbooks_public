# Cookbook Name:: app_php
#
# Copyright 2009, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

#
# Required attributes
#
set_unless[:php][:db_app_user] = ""   	     
set_unless[:php][:db_app_passwd] = ""       
set_unless[:php][:db_schema_name] = ""      
set_unless[:php][:db_dns_name] = "" 

set_unless[:php][:db_dumpfile_path] = ""         

#
# Recommended attributes
#
set_unless[:php][:server_name] = "myserver"  
set_unless[:php][:application_name] = "myapp"

#
# Optional attributes
#
set_unless[:php][:application_port] = "8000"    
set_unless[:php][:modules_list] = [] 
set_unless[:php][:db_adapter] = "mysql"

#
# Calculated attributes
#
set[:php][:code][:destination] = "/home/webapp/#{php[:application_name]}"

case platform
when "ubuntu", "debian"
  set[:php][:package_dependencies] = ["php5", "php5-mysql", "php-pear", "libapache2-mod-php5"] 
  set[:php][:module_dependencies] = [ "proxy_http", "php5"]
  set_unless[:php][:app_user] = "www-data"
when "centos","fedora","suse"
  set[:php][:package_dependencies] = ["php", "php-mysql", "php-pear"]
  set[:php][:module_dependencies] = []
  set_unless[:php][:app_user] = "apache"
end


