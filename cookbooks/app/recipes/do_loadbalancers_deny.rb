#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

sys_firewall "Close this appserver's ports to all loadbalancers" do
  machine_tag "loadbalancer:lb=#{node[:lb][:applistener_name]}"
  port node[:app][:port]
  enable false
  action :update
end

rs_utils_marker :end
