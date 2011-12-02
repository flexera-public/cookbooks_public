#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# convert inputs into parameters usable by the firewall_rule definition
# TODO add support for 'any' and port ranges '80,8000,3000-4000'
rule_port = node[:sys_firewall][:rule][:port].to_i
raise "Invalid port specified: #{node[:sys_firewall][:rule][:port]}.  Valid range 1-65536" unless rule_port > 0 and rule_port <= 65536
rule_ip = node[:sys_firewall][:rule][:ip_address]
rule_ip = (rule_ip == "" || rule_ip.downcase =~ /any/ ) ? nil : rule_ip 
rule_protocol = node[:sys_firewall][:rule][:protocol]
to_enable = (node[:sys_firewall][:rule][:enable] == "enable") ? true : false

if node[:sys_firewall][:enabled] == "enabled"

  sys_firewall rule_port do
    ip_addr rule_ip
    protocol rule_protocol
    enable to_enable
    action :update
  end

else 
  log "Firewall not enabled. Not adding rule for #{rule_port}."
end

rs_utils_marker :end
