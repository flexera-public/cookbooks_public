#
# Cookbook Name:: setup_server_tags
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# RightScale unique identifier
uuid = node[:rightscale][:instance_uuid]
log "Adding server tag for UUID #{uuid}"
right_link_tag "server:uuid=#{uuid}"

i=0
# Add a tag for each private IP address
while node[:cloud][:private_ips] && node[:cloud][:private_ips][i] do 
  ip = node[:cloud][:private_ips][i]
  log "Adding private ip tag for ip address #{ip}"
  right_link_tag "server:private_ip_#{i}=#{ip}"
  i += 1
end

i=0
# Add a tag for each public IP address
while node[:cloud][:public_ips] && node[:cloud][:public_ips][i] do 
  ip = node[:cloud][:public_ips][i]
  log "Adding public ip tag for ip address #{ip}"
  right_link_tag "server:public_ip_#{i}=#{ip}"
  i += 1
end

rs_utils_marker :end
