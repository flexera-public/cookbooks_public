maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "RightScale Database Manager"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2"

depends "rs_utils"
depends "block_device"
depends "sys_firewall"
depends "db_mysql"


recipe "db::default", "Adds the database:active=true tag to your server which identifies it as an database server. The tag is used by application servers to identify active databases. It also loads the required 'db' resources."

recipe  "db::install_client", "Installs the database client onto the VM so that it can connect to a running server.  It should be set up on all database servers and servers intended to connect to the servers."

recipe  "db::install_server", "Installs and sets up the packages that are required for database servers."

recipe  "db::setup_monitoring", "Installs the collectd plugin for database monitoring support, which is required to enable monitoring and alerting functionality for your servers."

# == Common Database Recipes
#
recipe  "db::do_backup", "Creates a backup of the database using persistent storage in the current cloud.  On Rackspace, LVM backups are uploaded to the specified CloudFiles container.  For all other clouds, volume snapshots (like EBS) are used."
recipe  "db::do_restore", "Restores the database from the most recently completed backup available in persistent storage of the current cloud."

recipe "db::do_backup_schedule_enable", "Enables db::do_backup to be run periodically."
recipe "db::do_backup_schedule_disable", "Disables db::do_backup from being run periodically."

recipe  "db::setup_privileges_admin", "Adds the username and password for 'superuser' privileges."
recipe  "db::setup_privileges_application", "Adds the username and password for application privileges."

recipe  "db::do_secondary_backup", "Creates a backup of the database and uploads it to a secondary cloud storage location, which can be used to migrate your database to a different cloud.  For example, you can save a secondary backup to an AWS S3 bucket or a Rackspace CloudFiles container."
recipe  "db::do_secondary_restore", "Restores the database from the most recently completed backup available in a secondary location."

recipe  "db::do_force_reset", "Resets the database back to a pristine state. WARNING: Execution of this script will delete any data in your database!"

recipe  "db::do_dump_export", "Creates a dump file and uploads it to an ROS."
recipe  "db::do_dump_import", "Retrieves a dump file from ROS and imports it into DB."
recipe  "db::do_dump_schedule_enable", "Schedules the daily run of do_dump_export."
recipe  "db::do_dump_schedule_disable", "Disables the daily run of do_dump_export."


# == Database Firewall Recipes
# 
recipe "db::do_appservers_allow", "Allows connections from all application servers in the deployment that are tagged with appserver:active=true tag. This script should be run on a database server so that it will accept connections from application servers."

recipe "db::do_appservers_deny", "Denies connections from all application servers in the deployment that are tagged with appserver:active=true tag.  This script can be run on a database server to deny connections from all application servers in the deployment."

recipe "db::request_appserver_allow", "Sends a request to allow connections from the caller's private IP address to all database servers in the deployment that are tagged with the database:active=true tag. This should be run on an application server before attempting a database connection."

recipe "db::request_appserver_deny", "Sends a request to deny connections from the caller's private IP address to all database servers in the deployment that are tagged with the database:active=true tag. This should be run on an application server upon decommissioning."


# == Master/Slave Recipes
#
recipe "db::do_init_and_become_master", "Initializes MySQL database.  Tag as Master.  Set Master DNS.  Kick off a fresh backup from this master."
recipe "db::do_restore_and_become_master", "Restore MySQL database.  Tag as Master.  Set Master DNS.  Kick off a fresh backup from this master."
recipe "db::do_secondary_restore_and_become_master", "Restore MySQL database from secondary backup location.  Tag as Master.  Set Master DNS.  Kick off a fresh backup from this master."
recipe "db::do_init_slave", "Initialize MySQL Slave"
recipe "db::do_init_slave_at_boot", "Initialize MySQL Slave at boot."
recipe "db::do_promote_to_master", "Promote a replicating slave to master"
recipe "db::setup_replication_privileges", "Set up privileges for MySQL replication slaves."
recipe "db::request_master_allow", "Sends a request to the master database server tagged with rs_dbrepl:master_instance_uuid=<master_instance_uuid> to allow connections from the server's private IP address.  This script should be run on a slave before it sets up replication."
recipe "db::request_master_deny", "Sends a request to the master database server tagged with rs_dbrepl:master_instance_uuid=<master_instance_uuid> to deny connections from the server's private IP address.  This script should be run on a slave when it stops replicating."

recipe "db::handle_demote_master", "Remote recipe executed by do_promote_to_master. DO NOT RUN."

recipe "db::do_terminate_server", "Deletes any currently attached volumes from the instance and then terminates the machine."

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
  :recipes => [ "db::install_server", "db::setup_privileges_admin" ]

attribute "db/admin/password",
  :display_name => "Database Admin Password",
  :description => "The password of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db::install_server", "db::setup_privileges_admin" ]

attribute "db/replication/user",
  :display_name => "Database Replication Username",
  :description => "The username of the database user that has 'replication' privileges.",
  :required => true,
  :recipes => [ "db::setup_replication_privileges", "db::do_restore_and_become_master", "db::do_secondary_restore_and_become_master", "db::do_init_and_become_master", "db::do_promote_to_master", "db::do_init_slave", "db::do_init_slave_at_boot" ]

attribute "db/replication/password",
  :display_name => "Database Replication Password",
  :description => "The password of the database user that has 'replciation' privileges.",
  :required => true,
  :recipes => [ "db::setup_replication_privileges", "db::do_restore_and_become_master", "db::do_secondary_restore_and_become_master", "db::do_init_and_become_master", "db::do_promote_to_master","db::do_init_slave", "db::do_init_slave_at_boot" ]

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
  
attribute "db/init_slave_at_boot",
  :display_name => "Init Slave at Boot",
  :description => "Set to 'True' for the instance to initialize the database server as a slave at boot time.   Set to 'False' if there is no Master-DB server running. ",
  :default => "false",
  :choice => [ "true", "false" ],
  :recipes => [ "db::do_init_slave_at_boot" ]


# == Backup/Restore 
#
attribute "db/backup/lineage",
  :display_name => "Backup Lineage",
  :description => "The prefix that will be used to name/locate the backup of a particular database.",
  :required => true,
  :recipes => [
    "db::do_init_slave",
    "db::do_init_slave_at_boot",
    "db::do_promote_to_master",
    "db::do_restore_and_become_master",
    "db::do_secondary_restore_and_become_master",
    "db::do_init_and_become_master",
    "db::do_backup",
    "db::do_restore",
    "db::do_backup_schedule_enable",
    "db::do_backup_schedule_disable",
    "db::do_force_reset",
    "db::do_secondary_backup",
    "db::do_secondary_restore"
  ]
  
attribute "db/backup/timestamp_override",
  :display_name => "Restore Timestamp Override", 
  :description => "An optional variable to restore from a specific timestamp. You must specify a string that matches the timestamp tag on the volume snapshot.  You will need to specify the timestamp that's defined by the snapshot's tag (not the name).  For example, if the snapshot's tag is 'rs_backup:timestamp=1303613371' you would specify '1303613371' for this input.",
  :required => false,
  :recipes => [ "db::do_restore", "db::do_secondary_restore", "db::do_secondary_restore_and_become_master" ]
  
attribute "db/backup/secondary_location",
  :display_name => "Secondary Backup Location",
  :description => "Location for secondary backups. Used by db::do_secondary_backup and db::do_secondary_restore to backup to persistent storage outside of the current cloud. For example, you can specify the name of an AWS S3 bucket or Rackspace CloudFiles container.",
  :default => "S3",
  :choice => [ "S3", "CloudFiles" ],
  :recipes => [ "db::do_secondary_backup", "db::do_secondary_restore", "db::do_secondary_restore_and_become_master" ]

attribute "db/backup/secondary_container",
  :display_name => "Secondary Backup Container",
  :description => "Container for secondary backups. Used by db::do_secondary_backup and db::do_secondary_restore to backup to persistent storage outside of the current cloud. For example, you can specify the name of an AWS S3 bucket or Rackspace CloudFiles container.",
  :required => true,
  :recipes => [ "db::do_secondary_backup", "db::do_secondary_restore", "db::do_secondary_restore_and_become_master" ]

attribute "db/backup/master/hour",
  :display_name => "Master Backup Cron Hour",
  :description => "Defines the hour of the day when the backup EBS snapshot will be taken of the Master database.  Backups of the Master are taken daily.  By default, an hour will be randomly chosen at launch time.  The time of the backup is defined by 'Master Backup Cron Hour' and 'Master Backup Cron Minute'.  Uses standard crontab format. (Ex: 23) for 11pm.",
  :required => false,
  :recipes => [ 'db::do_backup_schedule_enable' ]

attribute "db/backup/slave/hour",
  :display_name => "Slave Backup Cron Hour",
  :description => "By default, backup EBS Snapshots of the Slave database are taken hourly. (Ex: *)",
  :required => false,
  :recipes => [ 'db::do_backup_schedule_enable' ]

attribute "db/backup/master/minute",
  :display_name => "Master Backup Cron Minute",
  :description => "Defines the minute of the hour when the backup EBS snapshot will be taken of the Master database.  Backups of the Master are taken daily.  By default, a minute will be randomly chosen at launch time.  The time of the backup is defined by 'Master Backup Cron Hour' and 'Master Backup Cron Minute'.  Uses standard crontab format. (Ex: 30) for the 30th minute of the hour.",
  :required => false,
  :recipes => [ 'db::do_backup_schedule_enable' ]

attribute "db/backup/slave/minute",
  :display_name => "Slave Backup Cron Minute",
  :description => "Defines the minute of the hour when the backup EBS snapshot will be taken of the Slave database.  Backups of the Slave are taken hourly.  By default, a minute will be randomly chosen at launch time.  Uses standard crontab format. (Ex: 30) for the 30th minute of the hour.",
  :required => false,
  :recipes => [ 'db::do_backup_schedule_enable' ]


# == Import/export attributes
#

attribute "db/dump",
  :display_name => "Import/Export settings for Database dump file management.",
  :type => "hash"

attribute "db/dump/storage_account_provider",
  :display_name => "Dump Storage Account Provider",
  :description => "Location where dump file will be saved.  Used by dump recipes to backup to Amazon S3 or Rackspace Cloud Files.",
  :required => "required",
  :choice => [ "S3", "CloudFiles" ],
  :recipes => [ "db::do_dump_import", "db::do_dump_export", "db::do_dump_schedule_enable" ]

attribute "db/dump/storage_account_id",
  :display_name => "Dump Storage Account Id",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use AWS_ACCESS_KEY_ID. For Rackspace Cloud Files, use your Rackspace login Username.",
  :required => "required",
  :recipes => [ "db::do_dump_import", "db::do_dump_export", "db::do_dump_schedule_enable" ]

attribute "db/dump/storage_account_secret",
  :display_name => "Dump Storage Account Secret",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use AWS_SECRET_ACCESS_KEY. For Rackspace Cloud Files, use your Rackspace account API Key.",
  :required => "required",
  :recipes => [ "db::do_dump_import", "db::do_dump_export", "db::do_dump_schedule_enable" ]

attribute "db/dump/container",
  :display_name => "Dump Container",
  :description => "The cloud storage location where the dump file will be saved to or restored from. For Amazon S3, use the bucket name.  For Rackspace Cloud Files, use the container name.",
  :required => "required",
  :recipes => [ "db::do_dump_import", "db::do_dump_export", "db::do_dump_schedule_enable" ]

attribute "db/dump/prefix",
  :display_name => "Dump Prefix",
  :description => "The prefix that will be used to name/locate the backup of a particular db dump.  Defines the prefix of the dump filename that will be used to name the backup database dumpfile along with a timestamp.",
  :required => "required",
  :recipes => [ "db::do_dump_import", "db::do_dump_export", "db::do_dump_schedule_enable" ]

attribute "db/dump/database_name",
  :display_name => "Dump Schema/Database Name",
  :description => "Enter the name of the database name/schema to create/restore a dump from/for. Ex: mydbschema",
  :required => "required",
  :recipes => [ "db::do_dump_import", "db::do_dump_export", "db::do_dump_schedule_enable" ]

attribute "db/terminate_safety",
  :display_name => "Terminate Saftey",
  :description => "Prevents the accidental running of the db::do_teminate_server recipe.  This recipe will only run if the input variable is overridden and set to \"off\".",
  :type => "string",
  :choice => ["Override the dropdown and set to \"off\" to really run this recipe"],
  :default => "Override the dropdown and set to \"off\" to really run this recipe",
  :required => false,
  :recipes => [ "db::do_terminate_server" ]

attribute "db/force_safety",
  :display_name => "Force Reset Saftey",
  :description => "Prevents the accidental running of the db::do_force_reset recipe.  This recipe will only run if the input variable is overridden and set to \"off\".",
  :type => "string",
  :choice => ["Override the dropdown and set to \"off\" to really run this recipe"],
  :default => "Override the dropdown and set to \"off\" to really run this recipe",
  :required => false,
  :recipes => [ "db::do_force_reset" ]


