maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures app_passenger"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends 'rs_utils'
depends 'web_apache'
depends "repo_git"
depends "logrotate"
depends "app"
depends "db"

recipe "app_passenger::default", "default cookbook recipe"
recipe "app_passenger::install_custom_gems", "Custom gems install."
recipe "app_passenger::install_required_app_gems", "Bundler gems Install. Gemfile must be present in app directory."
recipe "app_passenger::install_apache_rails_passenger_http_only_vhost", "Install and configure passenger module"
recipe "app_passenger::install_ruby_enterprise_edition", "Install Ruby EE"
recipe "app_passenger::svn_code_update_and_db_config", "Configures rails deploy environment"
recipe "app_passenger::install_sqlite3_gem", "Recipe created to fix problems with installation of sqlite3 gem on RHEL based systems."
recipe "app_passenger::run_custom_rails_commands", "Run specific user defined commands Commands will be executed in the app directory. Command path ../rails/bin/"
recipe "app_passenger::rhel_apache_fix", "Temporary recipe for fixing apache bug on red hat image"


attribute "app_passenger/environment",
  :display_name => "Rails Environment",
  :description => "Creates a Rails environment shell script, and adds it to the system profile (/etc/profile.d) so that any shell can use it. This script simply exports the RAILS ENV environment variable. ",
  :default => "production",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/port",
  :display_name => "Application Apache Port",
  :description => "Apache port number for your application Ex: 8000",
  :default => "8000",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/opt_gems_list",
     :display_name => "Custom gems list",
     :description => "A space-separated list of optional gem(s). Format:  ruby-Gem1:version  ruby-Gem2:version ruby-Gem3 ",
     :default => "",
     :recipes => ["app_passenger::install_custom_gems"]

attribute "app_passenger/opt_custom_cmd",
     :display_name => "Custom rails/bin/ command",
     :description => "A comma separated list of optional commands which will be executed in app directory. Ex: rake gems:install, rake db:create, rake get_common",
     :default => "",
     :recipes => ["app_passenger::run_custom_rails_commands"]

attribute "app_passenger/spawn_method",
  :display_name => "Rails spawn method",
  :description => "The  spawn method that Phusion Passenger will use.  The choices are: smart, smart-lv2, and conservative.  Ex: conservative",
  :choice => ["conservative", "smart-lv2", "smart"],
  :default => "conservative",
  :recipes => ["app_passenger::install_apache_rails_passenger_http_only_vhost"]

attribute "app_passenger/opt_maintenance_page",
  :display_name => "Maintenance page",
  :description => "Maintenance URI to show if the page exists (based on document root). Default: [document root]/system/maintenance.html.  If this file exists, your site will show a &quot;Under Maintenance&quot; page and your site will not be available.",
  :default => "",
  :recipes => ["app_passenger::install_apache_rails_passenger_http_only_vhost"]

attribute "app_passenger/opt_php_enable",
  :display_name => "PHP Support",
  :description => "Enables PHP support for Apache by enabling PHP module.  Required to execute PHP scripts.",
  :choice => ["true", "false"],
  :required => false,
  :default => "false",
  :recipes => ["app_passenger::install_apache_rails_passenger_http_only_vhost"]

attribute "app_passenger/opt_serve_local_files",
  :display_name => "Serve local Files",
  :description => "This option tells Apache whether it should serve the (static) content itself. Currently, it will omit PHP and TomCat dynamic content, such as *.php, *.action, *.jsp, and *.do    Ex:  true",
  :required => false,
  :default => "true",
  :recipes => ["app_passenger::install_apache_rails_passenger_http_only_vhost"]

attribute "app_passenger/opt_target_bind_address",
  :display_name => "Target bind address",
  :description => "The IP address that Apache will redirect the requests to. Most likely this will always be set to localhost.",
  :required => false,
  :default => "",
  :recipes => ["app_passenger::install_apache_rails_passenger_http_only_vhost"]

attribute "app_passenger/opt_target_bind_port",
  :display_name => "Target bind port",
  :description => "The port address that Apache will redirect the requests to.  Default: 85",
  :required => false,
  :default => "",
  :recipes => ["app_passenger::install_apache_rails_passenger_http_only_vhost"]

attribute "app_passenger/opt_svn_type",
  :display_name => "Repository Type",
  :description => "Choose type of Repository SVN or GIT",
  :choice => ["git", "svn"],
  :default => "git",
  :required => "optional",
  :recipes => [ "app_passenger::svn_code_update_and_db_config" ]

attribute "app_passenger/opt_svn_revision",
  :display_name => "Repository branch",
  :description => "Enter branch of your repo you want ot fetch  Default: HEAD ",
  :required => false,
  :default => "HEAD",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/opt_svn_repository",
  :display_name => "Application repository URL",
  :description => "The URL of your SVN or git repository where your application code will be checked out from.  Ex: http://mysvn.net/app/ or git@github.com/whoami/project",
  :required => false,
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/opt_svn_username",
  :display_name => "SVN username",
  :description => "The SVN username that is used to checkout the application code from SVN repository.",
  :required => false,
  :default => "",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/opt_svn_password",
  :display_name => "SVN password",
  :description => "The SVN password that is used to checkout the application code from SVN repository.",
  :required => false,
  :default => "",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/opt_svn_credentials",
  :display_name => "SVN Repository Credentials",
  :description => "The private SSH key of the git repository.",
  :required => "optional",
  :recipes => [ "app_passenger::svn_code_update_and_db_config" ]

attribute "app_passenger/migration_cmd",
  :display_name => "Migration command",
  :description => "Rake command used to initiate migration Ex:rake db:bootstrap If you set value to ignore, migration process would not start.",
  :required => false,
  :recipes => [ "app_passenger::svn_code_update_and_db_config" ]

attribute "app_passenger/db_schema_name",
  :display_name => "DB schema name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up. This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :default => "",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]

attribute "app_passenger/adapter",
  :display_name => "Database adapter for database.yml ",
  :description => "Enter database adpter wich will be used to connect to the database Default: mysql",
  :default => "mysql",
  :recipes => ["app_passenger::svn_code_update_and_db_config"]
