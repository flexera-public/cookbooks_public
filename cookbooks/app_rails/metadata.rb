maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the rails application server on apache+passenger."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "web_apache"
depends "rails"
depends "passenger_apache2::mod_rails"
depends "mysql::client"
depends "db_mysql"

depends "resource:repo['default']" # not really in metadata spec yet. Format TBD.
 
recipe  "app_rails::default", "Runs app_rails::install_rails."
recipe  "app_rails::do_db_restore", "Restore the application database schema from a remote location."
recipe  "app_rails::do_update_code", "Update application source files from the remote repository."
recipe  "app_rails::install_rails", "Installs the rails application server."
recipe  "app_rails::setup_db_config", "Configures the rails database.yml file."

attribute "rails",
  :display_name => "Rails Passenger Settings",
  :type => "hash"
  
#
# required attributes
#
attribute "rails/db_app_user",
  :display_name => "Database User",
  :description => "If the MySQL administrator set up a restricted MySQL account for application servers to access the database, then specify the username of that account for this input.  If there is not a restricted MySQL account then use the same value that's used for 'Database Admin Username'.  The application server will then have unrestricted access to the database.",
  :required => true,
  :recipes => ["app_rails::do_db_restore", "app_rails::install_rails", "app_rails::default"]

attribute "rails/db_app_passwd",
  :display_name => "Database Password",
  :description => "If the MySQL administrator set up a restricted MySQL account for application servers to access the database, then specify the password of that account for this input.  If there is not a restricted MySQL account then use the same value that's used for 'Database Admin Password'.  The application server will then have unrestricted access to the database.",
  :required => true,
  :recipes => ["app_rails::do_db_restore"]

attribute "rails/db_schema_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :required => true,
  :recipes => ["app_rails::do_db_restore"]

#attribute "rails/db_dns_name",
#  :display_name => "Database DNS Name",
#  :description => "The fully qualified domain name of the database server to which the application server(s) will connect.  Ex: master.mydatabase.com",
#  :required => true,
#  :recipes => []

#
# recommended attributes
#
attribute "rails/server_name",
  :display_name => "Server Name",
  :description => "The fully qualified domain name of the application server used to define your virtual host.",
  :default => "myserver",
  :recipes => ["app_rails::do_db_restore", "app_rails::do_update_code", "app_rails::install_rails", "app_rails::default" ]

attribute "rails/application_name",
  :display_name => "Application Name",
  :description => "Sets the directory for your application's web files (/home/webapps/Application Name/current/).  If you have multiple applications, you can run the code checkout script multiple times, each with a different value for 'Application Name', so each application will be stored in a unique directory.  This must be a valid directory name.  Do not use symbols in the name.",
  :default => "myapp",
  :recipes => ["app_rails::install_rails", "app_rails::default" ]
  
#attribute "rails/environment",
#  :display_name => "Rails Environment",
#  :description => "The Rails Environment of the current workspace.",
#  :default => "production",
#  :recipes => ["app_rails::do_db_restore", "app_rails::do_update_code", "app_rails::install_rails" ]
  
attribute "rails/db_mysqldump_file_path",
  :display_name => "Mysqldump File Path",
  :description => "This input allows you to restore your database by choosing a specific MySQL database backup file.  You will need to specify a full path and/or filename.  Ex: branch/mydb-200910300402.gz",
  :recipes => ["app_rails::do_db_restore"]


#
# optional attributes
#
  
#attribute "rails/version",
#  :display_name => "Rails Version",
#  :description => "Specify which version of Rails to install.  Ex: 2.2.2",
#  :default => "false",
#  :recipes => ["app_rails::do_db_restore", "app_rails::do_update_code", "app_rails::install_rails" ]

#attribute "rails/max_pool_size",
#  :display_name => "Rails Max Pool Size",
#  :description => "Specify the MaxPoolSize in the Apache vhost.  Sets the number of desired mongrel processes on the Rails server.  Specify a value between 4-8 for a small instance.",
#  :default => "4",
#  :recipes => ["app_rails::do_db_restore", "app_rails::do_update_code", "app_rails::install_rails" ]
  
attribute "rails/application_port",
  :display_name => "Application Port",
  :description => "This input is normally set to 8000 if this server is a combined HAProxy and application server. If this is an application server (w/o HAproxy), set it to 80.  When setting this in a deployment, you should use 80 at the deployment level since you want all of your servers in the array to use this value.  If the server is a FE+APP server, you can set it to 8000 at the server level so that it overrides the deployment level input.",
  :default => "8000",
  :recipes => [ "app_rails::install_rails", "app_rails::default" ]

#attribute "rails/spawn_method",
#  :display_name => "Spawn Method",
#  :description => "Specify which Rails spawn method should be used. Ex: conservative, smart, smart-lv2",
#  :default => "conservative",
#  :recipes => ["app_rails::do_db_restore", "app_rails::do_update_code", "app_rails::install_rails" ]

attribute "rails/gems_list",
  :display_name => "Gems List",
  :description => "An optional list of gems that's required by your application.",
  :type => "array",
  :required => false,
  :recipes => [ "app_rails::install_rails", "app_rails::default" ]

