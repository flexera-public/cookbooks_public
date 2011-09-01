maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "RightScale Database Manager"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2"

depends "rs_utils"
depends "block_device"
depends "sys_firewall"

recipe "db::default", "Adds the database:active=true tag to your server which identifies it as an database server. This is used by application servers to identify active databases. Also loads the 'db' resource."

recipe  "db::install_client", "Installs the database client onto the VM so it can connect to a running server.  This should to be setup on all database servers and servers intended to connect to the servers."

recipe  "db::install_server", "Installs and sets up the packages that are required for database servers."

recipe  "db::setup_monitoring", "Install database collectd monitoring support.  This is required for monitoring and alerting for your servers."


# == Common Database Recipes
#
recipe  "db::setup_block_device", "Relocates the database data directory onto a block_device that supports snapshot backup and restore. This should be run on a newly operational server before it get placed into production."

recipe  "db::do_backup", "Creates a backup of the database using persistent storage in the current cloud.  On Rackspace snapshots are uploaded to CloudFiles.  For all other clouds, volume snapshots (like EBS) are used."
recipe  "db::do_restore", "Restores the database from the latest backup available in persistent storage of the current cloud."

recipe "db::do_backup_schedule_enable", "Enables db::do_backup to be run periodically."
recipe "db::do_backup_schedule_disable", "Disables db::do_backup from being run periodically."

recipe  "db::setup_privileges_admin", "Adds the username and password for 'superuser' privileges."
recipe  "db::setup_privileges_application", "Adds username and password for application privileges."

recipe  "db::do_secondary_backup", "Creates a backup of the database to a secondary location.  Current choices are AWS S3 or Rackspace's CloudFiles."
recipe  "db::do_secondary_restore", "Restores the database from the latest backup available in a secondary location."

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
  :description => "The fully qualified domain name for the Master Database.",
  :required => true,
  :recipes => [ "db::default" ]

attribute "db/admin/user",
  :display_name => "Database Admin Username",
  :description => "The username of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db::default", "db::do_backup", "db::setup_privileges_admin" ]

attribute "db/admin/password",
  :display_name => "Database Admin Password",
  :description => "The password of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db::default", "db::do_backup", "db::setup_privileges_admin" ]

attribute "db/application/user",
  :display_name => "Database Application Username",
  :description => "The username of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db::default", "db::setup_privileges_application" ]

attribute "db/application/password",
  :display_name => "Database Application Password",
  :description => "The password of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db::default", "db::setup_privileges_application" ]


# == Backup/Restore 
#
attribute "db/backup/lineage",
  :display_name => "Backup Lineage",
  :description => "The prefix that will be used to name/locate the backup of a particular database.",
  :required => true,
  :recipes => [ "db::do_backup", "db::do_restore", "db::do_backup_schedule_enable", "db::do_backup_schedule_disable", "db::setup_block_device", "db::do_force_reset", "db::do_secondary_backup", "db::do_secondary_restore" ]
  
attribute "db/backup/timestamp_override",
  :display_name => "Restore Timestamp Override", 
  :description => "An optional variable to restore from a specific timestamp. Specify a string matching the timestamp tags on the volume snapshot set.  You will need to specify the timestamp that's defined by the snapshot's tag (not name).  For example, if the snapshot's tag is 'rs_backup:timestamp=1303613371' you would specify '1303613371' for this input.",
  :required => false,
  :recipes => [ "db::do_restore", "db::do_secondary_restore" ]
  
attribute "db/backup/secondary_location",
  :display_name => "Secondary Backup Location",
  :description => "Location for secondary backups. Used by db::do_secondary_backup and db::do_secondary_restore to backup to persistent storage outside of the current cloud",
  :default => "S3",
  :choice => [ "S3", "CloudFiles" ],
  :recipes => [ "db::do_secondary_backup", "db::do_secondary_restore" ]

attribute "db/backup/secondary_container",
  :display_name => "Secondary Backup Container",
  :description => "Container for secondary backups. Used by db::do_secondary_backup and db::do_secondary_restore to backup to persistent storage outside of the current cloud",
  :required => true,
  :recipes => [ "db::do_secondary_backup", "db::do_secondary_restore" ]
