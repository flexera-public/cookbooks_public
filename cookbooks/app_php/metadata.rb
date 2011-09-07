maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the php application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "app"
depends "web_apache"
depends "db_mysql"
depends "repo_git"
depends "rs_utils"
 
recipe  "app_php::default", "Installs the php application server."
recipe  "app_php::do_update_code", "Updates application source files from the remote repository."
recipe  "app_php::setup_db_connection", "Set up the MySQL database db.php connection file."
recipe  "app_php::setup_php_application_vhost", "Set up the application vhost on port 8000."

attribute "php",
  :display_name => "PHP Application Settings",
  :type => "hash"
#
# optional attributes
#
attribute "php/server_name",
  :display_name => "Server Name",
  :description => "The fully qualified domain name of the application server used to define your virtual host.",
  :default => "myserver",
  :recipes => ["app_php::default" ]

attribute "php/modules_list",
  :display_name => "PHP module packages",
  :description => "An optional list of php module packages to install.  Accepts an array of package names (IE: php53u-mysql,php53u-pecl-memcache).  When using CentOS package names are prefixed with php53u instead of php.  To see a list of available php modules on CentOS run 'yum search php53u' on the server.",
  :type => "array",
  :default => [ "php53u-pear" ],
  :recipes => [  "app_php::default" ] 

attribute "php/db_schema_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema will be backed up.  Ex: mydbschema",
  :required => false,
  :recipes => [ "app_php::setup_db_connection"  ]

attribute "php/code",
  :display_name => "PHP Application Code",
  :type => "hash"
  
attribute "php/code/url",
  :display_name => "Repository URL",
  :description => "Specify the URL location of the repository that contains the application code. Ex: git://github.com/mysite/myapp.git",
  :required => true,
  :recipes => [ "app_php::do_update_code", "app_php::do_db_restore",  "app_php::default" ]

attribute "php/code/credentials",
  :display_name => "Repository Credentials",
  :description => "The private SSH key of the git repository.",
  :required => false,
  :default => "",
  :recipes => [ "app_php::do_update_code", "app_php::do_db_restore",  "app_php::default" ]

attribute "php/code/branch",
  :display_name => "Repository Branch",
  :description => "The name of the branch/tag/SHA within the git repository where the application code should be pulled from. Ex: mybranch",
  :required => true,
  :recipes => [ "app_php::do_update_code", "app_php::do_db_restore",  "app_php::default" ]
