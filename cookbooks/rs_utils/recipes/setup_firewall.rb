if node[:rs_utils][:firewall][:enabled] == "true" 
  include_recipe "iptables"
  rs_utils_firewall_rule "22" # SSH
  rs_utils_firewall_rule "80" # HTTP
  rs_utils_firewall_rule "443" # HTTPS
else
  service "iptables" do
    supports :status => true 
    action [:disable, :stop]
  end
end
