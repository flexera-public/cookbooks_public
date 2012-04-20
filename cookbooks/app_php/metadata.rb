maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs the php application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "app"
depends "web_apache"
depends "db_mysql"
depends "db_postgres"
depends "repo"
depends "rs_utils"
 
recipe  "app_php::default", "Installs the php application server."

attribute "php",
  :display_name => "PHP Application Settings",
  :type => "hash"

attribute "php/modules_list",
  :display_name => "PHP module packages",
  :description => "An optional list of php module packages to install.  Accepts an array of package names (IE: php53u-mysql,php53u-pecl-memcache).  When using CentOS, package names are prefixed with php53u instead of php.  To see a list of available php modules on CentOS, run 'yum search php53u' on the server.",
  :required => "optional",
  :type => "array"


attribute "php/db_schema_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema will be backed up.  Ex: mydbschema",
  :required => "recommended"


attribute "php/db_adapter",
  :display_name => "Database adapter for application ",
  :description => "Enter database adpter wich will be used to connect to the database Default: postgresql",
  :default => "mysql",
  :choice => [ "mysql", "postgresql" ],
  :recipes => ["app_php::default"]
