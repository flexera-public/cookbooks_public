# Cookbook Name:: app_php
#
# Copyright 2009, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

#
# Required attributes
#
set_unless[:php][:code][:url] = ""
set_unless[:php][:code][:credentials] = ""

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
set_unless[:php][:code][:branch] = "master" 
set_unless[:php][:application_port] = "8000"    
set_unless[:php][:modules_list] = ""
set_unless[:php][:db_adapter] = "mysql"

#
# Calculated attributes
#
set[:php][:code][:destination] = "/home/webapp/#{php[:application_name]}"

#
# Override attributes
#
# default apache is worker model -- use prefork for single thread
set_unless[:apache][:mpm] = "prefork" 

if php.has_key?(:application_port) 
  set[:apache][:listen_ports] = php[:application_port]
end
