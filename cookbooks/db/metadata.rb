maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs and configures the MySQL database."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"

recipe "db::default", "Adds the database:active=true tag to your server which identifies it as an database server. This is used by application servers to identify active databases."

recipe "db::do_appservers_allow", "Allow connections from all application servers in the deployment that are tagged with appserver:active=true. This should be run on a database server to allow application servers to connect."
recipe "db::do_appservers_deny", "Deny connections from all application servers in the deployment that are tagged with appserver:active=true.  This can be run on a database server to deny connections from all application servers in the deployment."

recipe "db::request_appserver_allow", "Sends request to allow connections from the caller's private IP address to all database servers in the deployment that are tagged with database:active=true. This should be run on a application server before attempting a database connection."

recipe "db::request_appserver_deny", "Sends request to deny connections from the caller's private IP address to all database servers in the deployment that are tagged with database:active=true.  This should be run on a application server upon decommissioning."

# == Premium Account Recipes
#
# The following recipes require a RightScale Premium ServerTemplate to run
#
recipe  "db::do_force_reset", "Reset the DB back to a pristine state."

recipe  "db::setup_block_device", "Creates, formats and mounts the block_device (volume) to the instance."

recipe  "db::do_backup", "Creates a backup of the MySQL data to the specified cloud storage location. (Premium Account Only) "

recipe  "db::do_restore", "Restores the MySQL database using a backup from the specified cloud storage location. (Premium Account Only) "

recipe "db::setup_continuous_backups", "Updates the crontab for taking continuous binary backups of the MySQL database."

recipe "db::do_disable_continuous_backups", "Disables continuous binary backups of the MySQL database by updating the crontab."

