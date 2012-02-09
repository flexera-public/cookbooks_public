maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Common utilities for RightScale managed application servers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"
depends "rs_utils"



recipe "app::default", "Adds the appserver:active=true tag to your server which identifies it as an application server. For example, database servers will update its firewall port permissions to accept incoming requests from application servers with this tag."

recipe "app::do_loadbalancers_allow", "Allows connections from all load balancers within a given listener pool which are tagged with loadbalancer:lb=<applistener_name>.  This script should be run on an application server before it makes a request to be connected to the load balancers."

recipe "app::do_loadbalancers_deny", "Denies connections from all load balancers which are tagged with loadbalancer:lb=<applistener_name>.  For example, you can run this script on an application server to deny connections from all load balancers within a given listener pool."

recipe "app::request_loadbalancer_allow", "Sends a request to all application servers tagged with loadbalancer:app=<applistener_name> to allow connections from the server's private IP address.  This script should be run on a load balancer before any application servers are attached to it."

recipe "app::request_loadbalancer_deny", "Sends a request to all application servers tagged with loadbalancer:app=<applistener_name> to deny connections from the server's private IP address.  This script should be run on a load balancer after disconnecting application servers or upon decommissioning."


recipe "app::do_package_install", "Install packages reqiured for App server"
recipe "app::do_setup_vhost", "Recipe for setup_vhost action execution"
recipe "app::do_setup_db_connection", "Recipe for setup_db_connection action execution"
recipe "app::do_start_app_server", "Recipe for start action execution"
recipe "app::do_restart_app_server", "Recipe for restart action execution"
recipe "app::do_stop_app_server", "Recipe for stop action execution"
recipe "app::do_code_update", "Recipe for code_update action execution"