maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs and configures the MySQL database."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "rs_utils"

recipe "db::do_firewall_open", ""
recipe "db::do_firewall_close", ""
recipe "db::do_firewall_request_open", ""
recipe "db::do_firewall_request_close", ""
