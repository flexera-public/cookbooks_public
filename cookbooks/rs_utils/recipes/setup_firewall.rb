if node[:rs_utils][:firewall][:enabled] == "true" 
  include_recipe "iptables"
  rs_utils_firewall_rule "22"
else
  service "iptables" do
    supports :status => true 
    action [:disable, :stop]
  end
end
