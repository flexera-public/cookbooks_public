# convert inputs into parameters usable by the firewall_rule definition
rule_port = node[:rs_utils][:firewall][:rule][:port]
rule_ip = node[:rs_utils][:firewall][:rule][:ip_address]
rule_ip = (rule_ip == "" || rule_ip.downcase =~ /any/ ) ? nil : rule_ip 
to_enable = (node[:rs_utils][:firewall][:rule][:enable] == "true") ? true : false

if node[:rs_utils][:firewall][:enabled] == "true"

  rs_utils_firewall_rule rule_port do
    ip_addr rule_ip
    enable to_enable
  end

else 
  log "Firewall not enabled. Not adding rule for #{rule_port}."
end

