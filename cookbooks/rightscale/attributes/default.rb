
#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.
 
 
set_unless node[:rightscale][:instance_uuid] = ""
set_unless node[:rightscale][:servers][:sketchy][:hostname] = ""

