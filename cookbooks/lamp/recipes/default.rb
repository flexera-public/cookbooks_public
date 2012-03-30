#
# Cookbook Name:: lamp
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set the LAMP specific node variables.  Make sure and run this recipe after the php application
# server default recipe to ensure that it does not over write these values.
rs_utils_marker :begin
  node[:db_mysql][:bind_address] = "localhost"
  node[:app][:port] = "80"
  log "LAMP set to listen on #{node[:db_mysql][:bind_address]}:#{node[:app][:port]}"
rs_utils_marker :end
