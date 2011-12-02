#
# Cookbook Name:: app 
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

sys_firewall "Request all appservers open ports to this loadbalancer" do
  machine_tag "loadbalancer:app=#{node[:lb][:applistener_name]}"
  port node[:app][:port]
  enable true
  ip_addr node[:cloud][:private_ips][0]
  action :update_request
end

rs_utils_marker :end
