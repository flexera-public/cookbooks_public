maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Common utilities for RightScale managed application servers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"

recipe "app::do_loadballancer_allow", "Allow connections from all loadbalancers in the deployment.  This should be run on an appserver before requesting connection to loadbalancers."
recipe "app::do_loadballancers_deny", "Deny connections from all loadbalancers in the deployment. This can be run on an appserver to deny connections from all loadbalancers in the deployment."
recipe "app::request_loadballancer_allow", "Sends request to all application servers to allow connections from the caller's private IP address. This should be run on a loadbalancer before attaching application servers."
recipe "app::request_loadballancer_deny", "Sends request to all application servers to deny connections from the caller's private IP address.  This should be run on a loadbalancer after disconnecting appservers or upon decommissioning."