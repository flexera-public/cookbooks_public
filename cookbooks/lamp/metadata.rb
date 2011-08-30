maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures lamp"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "db_mysql"
depends "app_php"


recipe "db::default", "Allows LAMP cookbook to override attributes from other cookbooks.  No installation of configuration is done"

