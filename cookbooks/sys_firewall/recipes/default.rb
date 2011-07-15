if node[:sys_firewall][:enabled] == "enabled" 
  include_recipe "iptables"
  sys_firewall "22" # SSH
  sys_firewall "80" # HTTP
  sys_firewall "443" # HTTPS
else
  service "iptables" do
    supports :status => true 
    action [:disable, :stop]
  end
end
