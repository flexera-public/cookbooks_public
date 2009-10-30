maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the php application server."
version          "0.0.1"

depends "web_apache"
depends "repo_git"
depends "repo_git_pull(url, branch, user, dest, cred)"
 
recipe  "app_php::default", "Runs app_php::install_php."
recipe  "app_php::do_update_code", "Update application source files from remote repository."
recipe  "app_php::install_php", "Installs the php application server."

attribute "php",
  :display_name => "PHP Application Settings",
  :type => "hash"
  
#
# required attributes
#
attribute "php/db_app_user",
  :display_name => "database user",
  :description => "username for database access",
  :required => true

attribute "php/db_app_passwd",
  :display_name => "database password",
  :description => "password for database access",
  :required => true

attribute "php/db_schema_name",
  :display_name => "database schema name",
  :description => "database schema to use",
  :required => true

attribute "php/db_dns_name",
  :display_name => "database dns name",
  :description => "FQDN of the database server",
  :required => true

attribute "php/code",
  :display_name => "PHP Application Code",
  :type => "hash"
  
attribute "php/code/url",
  :display_name => "repository url",
  :description => "location of application code repository",
  :required => true

attribute "php/code/user",
  :display_name => "repository username",
  :description => "username for code repository",
  :required => false,
  :default => ""  

attribute "php/code/credentials",
  :display_name => "repository credentials",
  :description => "credentials for code repository",
  :required => false,
  :default => ""  

#
# recommended attributes
#
attribute "php/server_name",
  :display_name => "server name",
  :description => "FQDN for the server",
  :required => true

attribute "php/application_name",
  :display_name => "application name",
  :description => "give a name to your application",
  :default => "myapp"
  
#
# optional attributes
#

attribute "php/code/branch",
  :display_name => "repository branch",
  :description => "branch to pull source from",
  :default => "master"
  
attribute "php/application_port",
  :display_name => "application port",
  :description => "the port your php application will listen on",
  :default => "8000"
