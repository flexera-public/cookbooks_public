maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs and configures the MySQL database."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "sys_firewall"
depends "block_device"

recipe "db::default", "Adds the database:active=true tag to your server which identifies it as an database server. This is used by application servers to identify active databases."

recipe  "db::install_client", "Installs the database client onto the VM so it can connect to a running server.  This should to be setup on all servers "
recipe  "db::install_server", "Installs and sets up the packages that are required for database servers."
recipe  "db::setup_monitoring", "Install database collectd monitoring support"


# == Common Database Recipes
#
recipe  "db::setup_block_device", "Relocates the database data directory onto a block_device that supports snapshot backup and restore. This should be run on a newly operational server before it get placed into production."

recipe  "db::do_backup", "Creates a backup of the database using persistent storage in the current cloud.  On Rackspace snapshots are uploaded to CloudFiles.  For all other clouds, volume snapshots (like EBS) are used."
recipe  "db::do_restore", "Restores the database from the latest backup available in persistent storage of the current cloud."

recipe "db::do_backup_schedule_enable", "Enables db::do_backup to be run periodically."
recipe "db::do_backup_schedule_disable", "Disables db::do_backup from being run periodically."

recipe  "db::setup_privileges_admin", "Adds the username and password for 'superuser' privileges."
recipe  "db::setup_privileges_application", "Adds username and password for application privileges."

recipe  "db::do_force_reset", "Reset the DB back to a pristine state. WARNING: this will delete any data in your database!"


# == Database Firewall Recipes
# 
recipe "db::do_appservers_allow", "Allow connections from all application servers in the deployment that are tagged with appserver:active=true. This should be run on a database server to allow application servers to connect."
recipe "db::do_appservers_deny", "Deny connections from all application servers in the deployment that are tagged with appserver:active=true.  This can be run on a database server to deny connections from all application servers in the deployment."

recipe "db::request_appserver_allow", "Sends request to allow connections from the caller's private IP address to all database servers in the deployment that are tagged with database:active=true. This should be run on a application server before attempting a database connection."

recipe "db::request_appserver_deny", "Sends request to deny connections from the caller's private IP address to all database servers in the deployment that are tagged with database:active=true.  This should be run on a application server upon decommissioning."


# == Common Database Attributes
#
attribute "db",
  :display_name => "General Database Options",
  :type => "hash"
  
attribute "db/fqdn",
  :display_name => "Database Master FQDN",
  :description => "The fully qualified hostname for the Master Database.",
  :required => true

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


# == Backup/Restore 
#
attribute "db/backup/lineage",
  :display_name => "Backup Lineage",
  :description => "The prefix that will be used to name/locate the backup of a particular database.",
  :required => true,
  :recipes => [ "db::do_backup", "db::do_restore", "db::do_backup_schedule_enable", "db::do_backup_schedule_disable" ]
