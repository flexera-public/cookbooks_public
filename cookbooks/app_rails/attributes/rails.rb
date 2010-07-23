# Cookbook Name:: app_rails
#
# Copyright 2009, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

#
# Required attributes
#
set_unless[:rails][:db_app_user] = ""   	     
set_unless[:rails][:db_app_passwd] = ""       
set_unless[:rails][:db_schema_name] = ""      
set_unless[:rails][:db_dns_name] = "" 

set_unless[:rails][:db_dumpfile_path] = ""         

#
# Recommended attributes
#
set_unless[:rails][:server_name] = "myserver"  
set_unless[:rails][:application_name] = "myapp"
set_unless[:rails][:env] = "production"       

#
# Optional attributes
#
set_unless[:rails][:application_port] = "8000"    
set_unless[:rails][:spawn_method] = "conservative"
set_unless[:rails][:gems_list] = ""
set_unless[:rails][:db_adapter] = "mysql"

#
# Calculated attributes
#
set[:rails][:code][:destination] = "/home/webapp/#{rails[:application_name]}"

#
# Platform specific attributes
#
case platform 
when "redhat","centos","fedora","suse"
  set_unless[:rails][:app_user] = "apache"
when "debian","ubuntu"
  set_unless[:rails][:app_user] = "www-data"
else 
  set_unless[:rails][:app_user] = "www-data"
end

