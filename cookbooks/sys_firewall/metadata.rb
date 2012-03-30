maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures firewall"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "iptables"
depends "sys"
depends "rs_utils"

recipe "sys_firewall::default", "Use in conjunction with the 'Firewall' input to enable or disable iptables."
recipe "sys_firewall::setup_rule", "Use for enabling/disabling specific firewall ports."
recipe "sys_firewall::do_list_rules", "List the firewall rules."

attribute "sys_firewall/enabled",
  :display_name => "Firewall",  
  :description => "Enables an iptables firewall for this server which allows port 22, 80 and 443 open by default.  Use the sys_firewall::setup_rule recipe to enable/disable extra ports.",
  :required => "optional",
  :choice => ["enabled", "disabled"],
  :default => "enabled",
  :recipes => [ "sys_firewall::default" ]

attribute "sys_firewall/rule/port",
  :display_name => "Firewall Rule Port",
  :description => "Firewall port to Enable or Disable. (Ex. 8000)",
  :required => "required",
  :recipes => [ "sys_firewall::setup_rule" ]
  
attribute "sys_firewall/rule/enable",
  :display_name => "Firewall Rule",
  :description => "Enables or disables a firewall rule.",
  :choice => ["enable", "disable"],
  :default => "enable",
  :recipes => [ "sys_firewall::setup_rule" ]

attribute "sys_firewall/rule/protocol",
  :display_name => "Firewall Rule Protocol",
  :description => "Firewall protocol use. Defaults to 'tcp'.",
  :choice => ["tcp", "udp", "all"],
  :default => "tcp",
  :recipes => [ "sys_firewall::setup_rule" ]

attribute "sys_firewall/rule/ip_address",  
  :display_name => "Firewall Rule IP Address",  
  :description => "Address can either be a network name, a network IP address (with /mask), or a plain IP address.  The mask can either be a network mask or a plain number specifying the number of 1's at the left side of the network mask.  Thus, a mask of 24 is equivalent to 255.255.255.0.  A '!' argument before the address specification inverts the sense of the address.  A value of 'any' allows any IP address (default).",
  :required => "optional",
  :default => "any",
  :recipes => [ "sys_firewall::setup_rule" ]
