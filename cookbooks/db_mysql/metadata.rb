maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures a MySQL database server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "db"
depends "block_device"
depends "sys_dns"
depends "rs_utils"

recipe  "db_mysql::default_5_1", "Set DB MySQL provider, set version 5.1 and node variables specific to MySQL 5.1"
recipe  "db_mysql::default_5_5", "Set DB MySQL provider, set version 5.5 and node variables specific to MySQL 5.5"
recipe  "db_mysql::default_server", "Set DB MySQL server specfic input variables"

attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"
  
# == Default attributes
#
attribute "db_mysql/server_usage",
  :display_name => "Server Usage",
  :description => "Use 'dedicated' if the mysql config file allocates all existing resources of the machine.  Use 'shared' if the MySQL config file is configured to use less resources so that it can be run concurrently with other apps like Apache and Rails for example.",
  :recipes => [ "db_mysql::default_server" ],
  :choice => ["shared", "dedicated"],
  :required => "optional",
  :default => "dedicated"

attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description => "Defines the filename and location of your MySQL stored binlog files.  This sets the log-bin variable in the MySQL config file.  If you do not specify an absolute path, it will be relative to the data directory. Ex: /mnt/mysql-binlogs/mysql-bin",
  :recipes => [ "db_mysql::default_server" ],
  :required => "optional",
  :default => "/mnt/mysql-binlogs/mysql-bin"

