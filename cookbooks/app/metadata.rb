maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Common utilities for RightScale managed application servers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"
depends "rs_utils"

recipe "app::default", "Adds the appserver:active=true tag to your server which identifies it as an application server. This tag is used by database servers, for example, for opening firewall ports."

recipe "app::do_loadbalancers_allow", "Allow connections from all load balancers within a given listener pool which are tagged with loadbalancer:lb=<applistener_name>.  This should be run on an application server before requesting connection to load balancers."

recipe "app::do_loadbalancers_deny", "Deny connections from all load balancers which are tagged with loadbalancer:lb=<applistener_name>. This can be run on an application server to deny connections from all load balancers within a given listener pool."

recipe "app::request_loadbalancer_allow", "Sends request to all application servers tagged with loadbalancer:app=<applistener_name> to allow connections from the caller's private IP address. This should be run on a load balancer before attaching application servers."

recipe "app::request_loadbalancer_deny", "Sends request to all application servers tagged with loadbalancer:app=<applistener_name> to deny connections from the caller's private IP address.  This should be run on a load balancer after disconnecting application servers or upon decommissioning."
