maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures a MySQL database server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "sys_dns"
depends "db"
depends "rs_utils"
depends "block_device"

provides "db_mysql_restore(url, branch, user, credentials, file_path, schema_name, tmp_dir)"
provides "db_mysql_set_privileges(type, username, password, db_name)"
provides "db_mysql_gzipfile_backup(db_name, file_path)"
provides "db_mysql_gzipfile_restore(db_name, file_path)"

recipe  "db_mysql::default", "Runs the client 'db::install_server' recipes."
recipe  "db_mysql::do_dump_import", "Initializes the MySQL database with a dumpfile from the specified cloud storage location. (i.e. S3, cloudfiles)"
recipe  "db_mysql::do_dump_export", "Uploads a MySQL dumpfile archive to the specified cloud storage location. (i.e. S3, cloudfiles)"
recipe  "db_mysql::setup_continuous_export", "Schedules the daily run of do_dump_export."

# == Master/Slave Recipes
recipe "db_mysql::default", "Installs dbtools"
recipe "db_mysql::do_restore_and_become_master", "Restore MySQL database.  Tag as Master.  Set Master DNS.  Kick off a fresh backup from this master."
recipe "db_mysql::do_init_slave", "Initialize MySQL Slave"
recipe "db_mysql::do_tag_as_master", "USE WITH CAUTION! Tag server with master tags and set master DNS to this server."
recipe "db_mysql::do_lookup_master", "Use tags to lookup current master and save in the node"
recipe "db_mysql::do_promote_to_master", "Promote a replicating slave to master"
recipe "db_mysql::setup_master_backup", "Set up crontab MySQL backup job with the master frequency and rotation."
recipe "db_mysql::setup_slave_backup", "Set up crontab MySQL backup job with the slave frequency and rotation."
recipe "db_mysql::setup_master_dns", "USE WITH CAUTION! Set master DNS to this server's IP"
recipe "db_mysql::setup_replication_privileges", "Set up privileges for MySQL replication slaves."
recipe "db_mysql::request_master_allow", "Sends a request to the master database server tagged with rs_dbrepl:master_instance_uuid=<master_instance_uuid> to allow connections from the server's private IP address.  This script should be run on a slave before it sets up replication."
recipe "db_mysql::request_master_deny", "Sends a request to the master database server tagged with rs_dbrepl:master_instance_uuid=<master_instance_uuid> to deny connections from the server's private IP address.  This script should be run on a slave when it stops replicating."


attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"
  
# == Default attributes
#
attribute "db_mysql/server_usage",
  :display_name => "Server Usage",
  :description => "Use 'dedicated' if the mysql config file allocates all existing resources of the machine.  Use 'shared' if the MySQL config file is configured to use less resources so that it can be run concurrently with other apps like Apache and Rails for example.",
  :recipes => [
    "db_mysql::default"
  ],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"

attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description => "Defines the filename and location of your MySQL stored binlog files.  This sets the log-bin variable in the MySQL config file.  If you do not specify an absolute path, it will be relative to the data directory. Ex: /mnt/mysql-binlogs/mysql-bin",
  :recipes => [
    "db_mysql::default"
  ],
  :default => "/mnt/mysql-binlogs/mysql-bin"


# == Import/export attributes
# TODO: these are used by the LAMP template and should be moved into the LAMP cookbook
#
attribute "db_mysql/dump",
  :display_name => "Import/Export settings for MySQL dump file management.",
  :type => "hash"

attribute "db_mysql/dump/schema_name",
  :display_name => "Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :required => false,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_provider",
  :display_name => "Storage Account Provider",
  :description => "Select the cloud infrastructure where the backup will be saved. For Amazon S3, use ec2.  For Rackspace Cloud Files, use rackspace.",
  :choice => ["ec2", "rackspace"],
  :required => false,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_id",
  :display_name => "Storage Account Id",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use AWS_ACCESS_KEY_ID. For Rackspace Cloud Files, use your Rackspace login Username.",
  :required => false,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_secret",
  :display_name => "Storage Account Secret",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use AWS_SECRET_ACCESS_KEY. For Rackspace Cloud Files, use your Rackspace account API Key.",
  :required => false,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/container",
  :display_name => "Container",
  :description => "The cloud storage location where the MySQL dump file will be saved to or restored from. For Amazon S3, use the bucket name.  For Rackspace Cloud Files, use the container name.",
  :required => false,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/prefix",
  :display_name => "Prefix",
  :description => "The prefix that will be used to name/locate the backup of a particular MySQL database.  Defines the prefix of the MySQL dump filename that will be used to name the backup database dumpfile along with a timestamp.",
  :required => false,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

# == Master/Slave Attributes
attribute "db_mysql/backup/master/hour",
  :display_name => "Master Backup Cron Hour",
  :description => "Defines the hour of the day when the backup EBS snapshot will be taken of the Master database.  Backups of the Master are taken daily.  By default, an hour will be randomly chosen at launch time.  The time of the backup is defined by 'Master Backup Cron Hour' and 'Master Backup Cron Minute'.  Uses standard crontab format. (Ex: 23) for 11pm.",
  :required => false,
  :recipes => [ "db_mysql::setup_slave_backup", "db_mysql::setup_master_backup", "db_mysql::do_disable_backup", "db_mysql::do_enable_backup" ]

attribute "db_mysql/backup/slave/hour",
  :display_name => "Slave Backup Cron Hour",
  :description => "By default, backup EBS Snapshots of the Slave database are taken hourly. (Ex: *)",
  :required => false,
  :recipes => [ "db_mysql::setup_slave_backup", "db_mysql::setup_master_backup", "db_mysql::do_disable_backup", "db_mysql::do_enable_backup" ]

attribute "db_mysql/backup/master/minute",
  :display_name => "Master Backup Cron Minute",
  :description => "Defines the minute of the hour when the backup EBS snapshot will be taken of the Master database.  Backups of the Master are taken daily.  By default, a minute will be randomly chosen at launch time.  The time of the backup is defined by 'Master Backup Cron Hour' and 'Master Backup Cron Minute'.  Uses standard crontab format. (Ex: 30) for the 30th minute of the hour.",
  :required => false,
  :recipes => [ "db_mysql::setup_slave_backup", "db_mysql::setup_master_backup", "db_mysql::do_disable_backup", "db_mysql::do_enable_backup" ]

attribute "db_mysql/backup/slave/minute",
  :display_name => "Slave Backup Cron Minute",
  :description => "Defines the minute of the hour when the backup EBS snapshot will be taken of the Slave database.  Backups of the Slave are taken hourly.  By default, a minute will be randomly chosen at launch time.  Uses standard crontab format. (Ex: 30) for the 30th minute of the hour.",
  :required => false,
  :recipes => [ "db_mysql::setup_slave_backup", "db_mysql::setup_master_backup", "db_mysql::do_disable_backup", "db_mysql::do_enable_backup" ]

