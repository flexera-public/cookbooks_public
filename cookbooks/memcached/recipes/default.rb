#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


#server tags
right_link_tag "memcached_server:active=true"                                  #The instance is identified as a memcached server.
right_link_tag "memcached_port:#{node[:memcached][:port]}"                     #The port
right_link_tag "memcached_cluster:#{node[:memcached][:cluster_id]}"            #The instance is associated with a cluster
right_link_tag "memcached_server:uuid=#{node[:rightscale][:instance_uuid]}"    #The server name so that sorts can be done to get the correct order across app servers.


#run setup
include_recipe "memcached::install_server"


rs_utils_marker :end