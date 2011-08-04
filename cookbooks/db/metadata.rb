maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs and configures the MySQL database."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"
depends "block_device"


recipe "db::default", "Adds the database:active=true tag to your server which identifies it as an database server. This is used by application servers to identify active databases."

recipe "db::do_appservers_allow", "Allow connections from all application servers in the deployment that are tagged with appserver:active=true. This should be run on a database server to allow application servers to connect."
recipe "db::do_appservers_deny", "Deny connections from all application servers in the deployment that are tagged with appserver:active=true.  This can be run on a database server to deny connections from all application servers in the deployment."

recipe "db::request_appserver_allow", "Sends request to allow connections from the caller's private IP address to all database servers in the deployment that are tagged with database:active=true. This should be run on a application server before attempting a database connection."

recipe "db::request_appserver_deny", "Sends request to deny connections from the caller's private IP address to all database servers in the deployment that are tagged with database:active=true.  This should be run on a application server upon decommissioning."

