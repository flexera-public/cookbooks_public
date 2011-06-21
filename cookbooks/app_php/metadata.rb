maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the php application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "web_apache"
depends "repo_git"
depends "repo_git_pull(url, branch, dest, cred)"
 
recipe  "app_php::default", "Installs the php application server."
recipe  "app_php::setup_apache_vhost", "Setup PHP Apache vhost."
recipe  "app_php::setup_http_only_vhost", "Setup PHP Apache vhost."
recipe  "app_php::do_update_code", "Update application source files from the remote repository."
recipe  "app_php::setup_db_connection", "Setup MySQL database db.php connection file."

attribute "php",
  :display_name => "PHP Application Settings",
  :type => "hash"

#
# recommended attributes
#
attribute "php/server_name",
  :display_name => "Server Name",
  :description => "The fully qualified domain name of the application server used to define your virtual host.",
  :default => "localhost",
  :recipes => [ "app_php::setup_apache_vhost", "app_php::setup_http_only_vhost" ]

attribute "php/application_name",
  :display_name => "Application Name",
  :description => "Sets the directory for your application's web files (/home/webapps/Application Name/current/).  If you have multiple applications, you can run the code checkout script multiple times, each with a different value for APPLICATION, so each application will be stored in a unique directory.  This must be a valid directory name.  Do not use symbols in the name.",
  :default => "myapp",
  :recipes => [  "app_php::default", "app_php::setup_http_only_vhost" ]
  
#
# optional attributes
#
attribute "php/modules_list",
  :display_name => "PHP modules",
  :discription => "An optional list of php modules to install",
  :type => "array",
  :recipes => [  "app_php::default" ] 

attribute "php/db_schema_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :required => false,
  :recipes => [ "app_php::setup_db_connection"  ]

attribute "php/code",
  :display_name => "PHP Application Code",
  :type => "hash"
  
attribute "php/code/url",
  :display_name => "Repository URL",
  :description => "Specify the URL location of the repository that contains the application code. Ex: git://github.com/mysite/myapp.git",
  :required => false,
  :recipes => [ "app_php::do_update_code", "app_php::do_db_restore",  "app_php::default" ]

attribute "php/code/credentials",
  :display_name => "Repository Credentials",
  :description => "The private SSH key of the git repository.",
  :required => false,
  :default => "",
  :recipes => [ "app_php::do_update_code", "app_php::do_db_restore",  "app_php::default" ]

attribute "php/code/branch",
  :display_name => "Repository Branch",
  :description => "The name of the branch within the git repository where the application code should be pulled from.",
  :default => "master",
  :recipes => [ "app_php::do_update_code", "app_php::do_db_restore",  "app_php::default" ]
  


