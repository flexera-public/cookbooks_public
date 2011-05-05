maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures database"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe  "database::do_backup", "Perform backup of given database to cloud storage."

attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"
  
attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description => "Defines the filename and location of your MySQL stored binlog files.  This sets the log-bin variable in the MySQL config file.  If you do not specify an absolute path, it will be relative to the data directory.",
  :recipes => [ "db_mysql::install_mysql", "db_mysql::default" ],
  :default => "/mnt/mysql-binlogs/mysql-bin"
  
attribute "db_mysql/datadir_relocate",
  :display_name => "MySQL Data-Directory Destination",
  :description => "Sets the final destination of the MySQL data directory. (i.e. an LVM or EBS volume)",
  :default => "/mnt/mysql"