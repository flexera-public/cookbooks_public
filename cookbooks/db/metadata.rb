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

recipe  "db::setup_block_device", "Relocates the database data_dir onto a block_device that supports snapshot backup and restore. (Premium Account Only) "

recipe  "db::do_backup", "Creates a backup of the database data_dir to the specified cloud storage location. (Premium Account Only) "

recipe  "db::do_restore", "Restores the MySQL database using a backup from the specified cloud storage location. (Premium Account Only) "

recipe "db::do_backup_schedule_enable", "Updates the crontab for taking continuous binary backups of the database. (Premium Account Only) "

recipe "db::do_backup_schedule_disable", "Disables continuous binary backups of the database by updating the crontab. (Premium Account Only)"

recipe  "db::setup_privileges_admin.rb", "Adds the username and password for 'superuser' privileges."
recipe  "db::setup_privileges_application.rb", "Adds username and password for application privileges."

attribute "db",
  :display_name => "General Database Options",
  :type => "hash"
  
attribute "db/admin/user",
  :display_name => "Database Admin Username",
  :description => "The username of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db::default", "db::do_backup" ]

attribute "db/admin/password",
  :display_name => "Database Admin Password",
  :description => "The password of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db::default", "db::do_backup" ]
  
attribute "db/application/user",
  :display_name => "Database Application Username",
  :description => "The username of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db::default" ]

attribute "db/application/password",
  :display_name => "Database Application Password",
  :description => "The password of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db::default" ]


# == Backup/Restore (Premium Accounts only)
#
attribute "db/backup/lineage",
  :display_name => "Backup Lineage",
  :description => "The prefix that will be used to name/locate the backup of a particular MySQL database.",
  :required => true,
  :recipes => [ "db::default", "db::do_backup", "db::do_restore", "db::do_backup_schedule_enable", "db::do_backup_schedule_disable" ]


