maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures firewall"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "iptables"

recipe "sys_firewall::default", "Use in conjunction with the node[:sys_firewall][:enabled] 
   input to enable or disable iptables."
recipe "sys_firewall::setup_rule", "Use for enabling/disabling specific ports."

attribute "sys_firewall/enabled",  
  :display_name => "Firewall",  
  :description => "Enables iptables firewall for this server which allows port 22, 80 and 443 open by default.  Use sys_firewall::setup_rule recipe to enable/disable extra ports.",
  :required => "optional",
  :choice => ["enabled", "disabled"],
  :default => "enabled",
  :recipes => [ "sys_firewall::default", "sys_firewall::setup_rule" ]

attribute "sys_firewall/rule/enable",  
  :display_name => "Firewall Rule",  
  :description => "Enables/Disables a firewall rule.",
  :choice => ["enabled", "disabled"],
  :default => "enabled",
  :recipes => [ "sys_firewall::setup_rule" ]

attribute "sys_firewall/rule/port",  
  :display_name => "Firewall Rule Port",  
  :description => "Firewall port to Enable/Disable.",
  :required => "required",
  :recipes => [ "sys_firewall::setup_rule" ]

attribute "sys_firewall/rule/ip_address",  
  :display_name => "Firewall Rule IP Address",  
  :description => "Specific IP Address to enable/disable the port for. A value of 'any' allow any IP address",
  :required => "optional",
  :default => "any",
  :recipes => [ "sys_firewall::setup_rule" ]