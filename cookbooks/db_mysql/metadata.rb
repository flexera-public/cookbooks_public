maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures a MySQL database server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

provides "db_mysql_restore(url, branch, user, credentials, file_path, schema_name, tmp_dir)"
provides "db_mysql_set_privileges(type, username, password, db_name)"
provides "db_mysql_gzipfile_backup(db_name, file_path)"
provides "db_mysql_gzipfile_restore(db_name, file_path)"

recipe  "db_mysql::default", "Runs the 'install_mysql' recipes."
recipe  "db_mysql::install_client", "Installs the MySQL client packages and gem."
recipe  "db_mysql::install_mysql", "Installs packages required for MySQL servers without manual intervention."
recipe  "db_mysql::do_move_datadir", "Move the datadir to /mnt/mysql"
recipe  "db_mysql::setup_mysql", "Configures server"
recipe  "db_mysql::setup_admin_privileges", "Add username and password for superuser privileges."
recipe  "db_mysql::setup_application_privileges", "Add username and password for application privileges."
recipe  "db_mysql::setup_my_cnf", "Creates the my.cnf configuration file"
recipe  "db_mysql::do_dump_import", "Initialize MySQL with dumpfile from cloud object store (i.e. S3, cloudfiles)"
recipe  "db_mysql::do_dump_export", "Upload MySQL dumpfile archive to cloud object store (i.e. S3, cloudfiles)"
recipe  "db_mysql::setup_continuous_export", "Schedule daily run of do_dump_export."

# == Premium Account Recipes
#
# The following recipes require a RightScale Premium ServerTemplate to run
#
recipe  "db_mysql::do_backup", "Snapshot MySQL data to selected cloud storage. (Premium Account Only) "

#
# required attributes
#
attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"
  
attribute "db_mysql/fqdn",
  :display_name => "Database Master FQDN",
  :description => "The fully qualified hostname for the MySQL Master Database.",
  :required => true

attribute "db_mysql/admin/user",
  :display_name => "Database Admin Username",
  :description => "The username of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db_mysql::setup_admin_privileges", "db_mysql::do_backup" ]

attribute "db_mysql/admin/password",
  :display_name => "Database Admin Password",
  :description => "The password of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db_mysql::setup_admin_privileges", "db_mysql::do_backup" ]
  
attribute "db_mysql/application/user",
  :display_name => "Database Application Username",
  :description => "The username of the database user that has 'user' privileges.",
  :required => true

attribute "db_mysql/application/password",
  :display_name => "Database Application Password",
  :description => "The password of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db_mysql::setup_application_privileges" ]

  
# == Backup/Restore (Premium Accounts only)
#
attribute "db_mysql/backup/storage_type",
  :display_name => "Backup Storage Type",
  :description => "TODO",
  :choice => ["ebs", "s3", "cloudfiles"],
  :type => "string",
  :default => "ebs",
  :recipes => [ "db_mysql::do_backup" ]
  
attribute "db_mysql/backup/lineage",
  :display_name => "Backup Lineage",
  :description => "TODO",
  :required => true,
  :recipes => [ "db_mysql::do_backup" ]

attribute "db_mysql/backup/max_snapshots",
  :display_name => "Backups Maximum",
  :description => "TODO",
  :default => "60",
  :recipes => [ "db_mysql::do_backup" ]
  
attribute "db_mysql/backup/keep_daily",
  :display_name => "Backups Keep Daily",
  :description => "TODO",
  :default => "14",
  :recipes => [ "db_mysql::do_backup" ]
  
attribute "db_mysql/backup/keep_weekly",
  :display_name => "Backups Keep Weekly",
  :description => "TODO",
  :default => "6",
  :recipes => [ "db_mysql::do_backup" ]
  
attribute "db_mysql/backup/keep_monthly",
  :display_name => "Backups Keep Monthly",
  :description => "TODO",
  :default => "12",
  :recipes => [ "db_mysql::do_backup" ]
  
attribute "db_mysql/backup/keep_yearly",
  :display_name => "Backups Keep Yearly",
  :description => "TODO",
  :default => "2",
  :recipes => [ "db_mysql::do_backup" ]

# Remote Object Storage account info (S3, CloudFiles)
attribute "db_mysql/backup/storage_account_id",
  :display_name => "Backup Storage Account ID",
  :description => "TODO (for backup to S3 or CloudFiles Remote Object Store)",
  :default => "",
  :recipes => [ "db_mysql::do_backup" ]

attribute "db_mysql/backup/storage_account_secret",
  :display_name => "Backup Storage Account Secret",
  :description => "TODO (for backup to S3 or CloudFiles Remote Object Store)",
  :default => "",
  :recipes => [ "db_mysql::do_backup" ]

attribute "db_mysql/backup/storage_container",
  :display_name => "Backup Storage Container",
  :description => "TODO (for backup to S3 or CloudFiles Remote Object Store)",
  :default => "",
  :recipes => [ "db_mysql::do_backup" ]

  
# == Import/export Attributes
#
attribute "db_mysql/dump",
  :display_name => "Import/Export settings for MySQL dump file management.",
  :type => "hash"

attribute "db_mysql/dump/schema_name",
  :display_name => "Schema Name",
  :description => "",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_provider",
  :display_name => "storage_account_provider",
  :description => "",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_id",
  :display_name => "storage_account_id",
  :description => "",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_secret",
  :display_name => "storage_account_secret",
  :description => "",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/container",
  :display_name => "container",
  :description => "",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/prefix",
  :display_name => "prefix",
  :description => "",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]  


#
# recommended attributes
#
attribute "db_mysql/server_usage",
  :display_name => "Server Usage",
  :description => "* dedicated (where the mysql config file allocates all existing resources of the machine)\n* shared (where the MySQL config file is configured to use less resources so that it can be run concurrently with other apps like Apache and Rails for example)",
  :recipes => [ "db_mysql::default" ],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"

#
# optional attributes
#
attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description => "Defines the filename and location of your MySQL stored binlog files.  This sets the log-bin variable in the MySQL config file.  If you do not specify an absolute path, it will be relative to the data directory.",
  :recipes => [ "db_mysql::setup_mysql" ],
  :default => "/mnt/mysql-binlogs/mysql-bin"
  
