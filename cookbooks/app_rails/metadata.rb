maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the rails application server on apache+passenger."
version          "0.0.1"

depends "web_apache"
depends "rails"
depends "passenger_apache2::mod_rails"
depends "mysql::client"
depends "repo_git"
depends "db_mysql"

depends "repo_git_pull(url, branch, user, dest, cred)"
 
recipe  "app_rails::default", "Runs app_rails::install_rails."
recipe  "app_rails::do_db_restore", "Restore application database schema from remote location."
recipe  "app_rails::do_update_code", "Update application source files from remote repository."
recipe  "app_rails::install_rails", "Installs the rails application server."
recipe  "app_rails::setup_db_config", "Configures the rails database.yml file"

attribute "rails",
  :display_name => "Rails Passenger Settings",
  :type => "hash"
  
#
# required attributes
#
attribute "rails/db_app_user",
  :display_name => "Database User",
  :description => "username for database access",
  :required => true

attribute "rails/db_app_passwd",
  :display_name => "Database Password",
  :description => "password for database access",
  :required => true

attribute "rails/db_schema_name",
  :display_name => "Database Schema Name",
  :description => "database schema to use",
  :required => true

attribute "rails/db_dns_name",
  :display_name => "Database DNS Name",
  :description => "FQDN of the database server",
  :required => true

attribute "rails/code",
  :display_name => "Rails Application Code",
  :type => "hash"
  
attribute "rails/code/url",
  :display_name => "Repository URL",
  :description => "location of application code repository",
  :required => true

attribute "rails/code/user",
  :display_name => "Repository Username",
  :description => "username for code repository",
  :required => true

attribute "rails/code/credentials",
  :display_name => "Repository Credentials",
  :description => "credentials for code repository",
  :required => true  

#
# recommended attributes
#
attribute "rails/server_name",
  :display_name => "Server Name",
  :description => "FQDN for the server",
  :default => "myserver"

attribute "rails/application_name",
  :display_name => "Application Name",
  :description => "Give a name to your application",
  :default => "myapp"
  
attribute "rails/environment",
  :display_name => "Rails Environment",
  :description => "Specify the environment to use for Rails",
  :default => "production"
  
attribute "rails/db_mysqldump_file_path",
  :display_name => "Mysqldump File Path",
  :description => "Full path in git repository to mysqldump file to restore"


#
# optional attributes
#
attribute "rails/version",
  :display_name => "Rails Version",
  :description => "Specify the version of Rails to install",
  :default => "false"

attribute "rails/max_pool_size",
  :display_name => "Rails Max Pool Size",
  :description => "Specify the MaxPoolSize in the Apache vhost",
  :default => "4"
  
attribute "rails/code/branch",
  :display_name => "Repository Branch",
  :description => "branch to pull source from",
  :default => "master"
  
attribute "rails/application_port",
  :display_name => "Application Port",
  :description => "the port your rails application will listen on",
  :default => "8000"

attribute "rails/spawn_method",
  :display_name => "Spawn Method",
  :description => "what spawn method should we use?",
  :default => "conservative"

attribute "rails/gems_list",
  :display_name => "Gems List",
  :description => "list of gems required by your application",
  :type => "array",
  :required => false

