# convert inputs into parameters usable by the firewall_rule definition
rule_port = node[:sys_firewall][:rule][:port]
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

