
# Request that all appservers open their client port to us.
action :firewall_set_request do
  to_enable = (new_resource.firewall_port_state.downcase =~ /open/) ? true : false
  client_ip = new_resource.firewall_client_ip
  server_tag = new_resource.firewall_server_tag
  rs_utils_firewall_request "Request all AppServer ports open" do
    machine_tag server_tag
    port 8000
    enable to_enable
    ip_addr client_ip
  end
end

# Open our client port for all tagged servers in deployment
action :firewall_set do
  to_enable = (new_resource.firewall_port_state.downcase =~ /open/) ? true : false
  client_tag = new_resource.firewall_client_tag
  rs_utils_firewall_rules "Open AppServer ports to all taged servers" do
    machine_tag client_tag
    port 8000
    enable to_enable
  end
end

