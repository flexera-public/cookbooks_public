maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Common utilities for RightScale managed application servers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "rs_utils"

recipe "app::do_firewall_open", ""
recipe "app::do_firewall_close", ""
recipe "app::do_firewall_request_open", ""
recipe "app::do_firewall_request_close", ""

#attribute "app/listener_name",
#  :display_name => "Applistener Name",
#  :description => "Sets the name of the load balance pool on frontends. Application severs will join this load balance pool by using this name.  Ex: www",
#  :recipes => [ 
#                'app::do_firewall_request_open',
#                'app::do_firewall_request_close'
#                ],
#  :required => true,
#  :default => nil
