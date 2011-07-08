actions :firewall_set, :firewall_set_request

# Firewall setttings
attribute :firewall_client_ip, :kind_of => String
attribute :firewall_client_tag, :kind_of => String
attribute :firewall_server_tag, :kind_of => String
attribute :firewall_port_state, :equal_to => [ "open", "closed" ]
