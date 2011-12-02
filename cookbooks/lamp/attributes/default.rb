#
# Cookbook Name:: lamp
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# LAMP should always listen on localhost
set[:db_mysql][:bind_address] = "localhost"
set[:app][:port] = 80

