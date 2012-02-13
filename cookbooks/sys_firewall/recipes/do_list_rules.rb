#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

if node[:sys_firewall][:enabled] == "enabled"
#
# List the contents of /etc/iptables.d
#
  bash "List contents of iptables.d" do
    user "root"
    code <<-EOH
      echo "==================== do_list_rules : /etc/iptables.d Begin =================="
      ls -l /etc/iptables.d
      echo "==================== do_list_rules : /etc/iptables.d End ===================="
    EOH
  end
#
# Directly list iptable rules
  bash "List contents of iptables.d" do
    user "root"
    code <<-EOH
      echo "==================== do_list_rules : Firewall rules Begin =================="
      iptables --list -n
      echo "==================== do_list_rules : Firewall rules End =================="
    EOH
  end
#

else
  log "Firewall not enabled."
end

rs_utils_marker :end
