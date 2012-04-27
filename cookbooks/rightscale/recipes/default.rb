#
# Cookbook Name:: rightscale.
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.
 
 
# Sets node[:rightscale] variables via attribute and metadata.
rs_utils_marker :begin
 
# Make sure these inputs are set.
raise "rightscale/instance_uuid must be set" unless node[:rightscale][:instance_uuid]
raise "rightscale/servers/sketchy/hostname must be set" unless node[:rightscale][:servers][:sketchy][:hostname]
 
log "rightscale/instance_uuid is  #{node[:rightscale][:instance_uuid]}"
log "rightscale/servers/sketchy/hostname is #{node[:rightscale][:servers][:sketchy][:hostname]}"

rs_utils_marker :end

