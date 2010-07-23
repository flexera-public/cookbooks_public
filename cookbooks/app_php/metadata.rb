maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the php application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "web_apache"

depends "resource:repo['default']" # not really in metadata spec yet. Format TBD.
 
recipe  "app_php::default", "Runs app_php::install_php."
recipe  "app_php::do_db_restore", "Restore the application database schema from a remote location."
recipe  "app_php::do_update_code", "Update application source files from the remote repository."
recipe  "app_php::install_php", "Installs the php application server."

attribute "php",
  :display_name => "PHP Application Settings",
  :type => "hash"
  
#
# required attributes
#
attribute "php/db_app_user",
  :display_name => "Database User",
  :description => "If the MySQL administrator set up a restricted MySQL account for application servers to access the database, then specify the username of that account for this input.  If there is not a restricted MySQL account then use the same value that's used for 'Database Admin Username'.  The application server will then have unrestricted access to the database.",
  :required => true,
  :recipes => [ "app_php::do_db_restore" ]

attribute "php/db_app_passwd",
  :display_name => "Database Password",
  :description => "If the MySQL administrator set up a restricted MySQL account for application servers to access the database, then specify the password of that account for this input.  If there is not a restricted MySQL account then use the same value that's used for 'Database Admin Password'.  The application server will then have unrestricted access to the database.",
  :required => true,
  :recipes => [ "app_php::do_db_restore" ]

attribute "php/db_schema_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :required => true,
  :recipes => [ "app_php::do_db_restore" ]

attribute "php/db_dns_name",
  :display_name => "Database Dns Name",
  :description => "The fully qualified domain name of the database server to which the application server(s) will connect.  Ex: master.mydatabase.com",
  :required => true,
  :recipes => [ "app_php::install_php", "app_php::default" ]
  
#
# recommended attributes
#
attribute "php/server_name",
  :display_name => "Server Name",
  :description => "The fully qualified domain name of the application server used to define your virtual host.",
  :required => true,
  :recipes => [ "app_php::install_php", "app_php::default" ]

attribute "php/application_name",
  :display_name => "Application Name",
  :description => "Sets the directory for your application's web files (/home/webapps/Application Name/current/).  If you have multiple applications, you can run the code checkout script multiple times, each with a different value for APPLICATION, so each application will be stored in a unique directory.  This must be a valid directory name.  Do not use symbols in the name.",
  :default => "myapp",
  :recipes => [ "app_php::install_php", "app_php::default" ]
  
attribute "php/db_mysqldump_file_path",
  :display_name => "Mysqldump File Path",
  :description => "This input allows you to restore your database by choosing a specific MySQL database backup file.  You will need to specify a full path and/or filename.  Ex: branch/mydb-200910300402.gz",
  :recipes => [ "app_php::do_db_restore" ]

#
# optional attributes
#
attribute "php/application_port",
  :display_name => "Application Port",
  :description => "This input is normally set to 8000 if this server is a combined HAProxy and application server. If this is an application server (w/o HAproxy), set it to 80.  When setting this in a deployment, you should use 80 at the deployment level since you want all of your servers in the array to use this value.  If the server is a FE+APP server, you can set it to 8000 at the server level so that it overrides the deployment level input.",
  :default => "8000",
  :recipes => [ "app_php::install_php", "app_php::default" ]

#attribute "php/modules_list",
#  :display_name => "PHP modules",
#  :discription => "An optional list of php modules to install",
#  :type => "array",
#  :recipes => [ "app_php::install_php" ] 

