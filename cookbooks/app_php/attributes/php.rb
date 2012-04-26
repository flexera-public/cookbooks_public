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
  when "centos","fedora","suse","redhat"
  set[:php][:module_dependencies] = [ "proxy", "proxy_http" ]
  set_unless[:php][:app_user] = "apache"
end

