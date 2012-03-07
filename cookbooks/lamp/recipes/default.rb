#
# Cookbook Name:: lamp
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe performs no actions.  It exists to allow overiding the attributes
# set in other cookbooks
rs_utils_marker :begin
  log "LAMP set to listen on #{node[:db_mysql][:bind_address]}:#{node[:app][:port]}"
rs_utils_marker :end
