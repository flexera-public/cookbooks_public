maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs and configures the MySQL database."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"

recipe "db::default", "Tags your server as a database. This is used by clients (like appserver) to identify active datbases."
recipe "db::do_appservers_allow", "Allow connections from all application servers in the deployment."
recipe "db::do_appservers_deny", "Deny connections from all application servers in the deployment."
recipe "db::request_appserver_allow", "Request all DBs allow connections from the calling server's private IP address."
recipe "db::request_appserver_deny", "Request all DBs deny connections from the calling server's private IP address."
