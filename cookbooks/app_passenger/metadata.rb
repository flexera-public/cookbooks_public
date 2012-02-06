maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures Apache Passenger Rails application server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends 'rs_utils'
depends 'web_apache'
depends "repo_git"
depends "logrotate"
depends "app"
depends "db"

provides "app"

recipe "app_passenger::default", "default cookbook recipe"
recipe "app_passenger::install_custom_gems", "Custom gems install."
recipe "app_passenger::install_required_app_gems", "Bundler gems Install. Gemfile must be present in app directory."
recipe "app_passenger::install_apache_passenger", "Install and apache passenger module"
recipe "app_passenger::setup_apache_passenger_vhost", "Configure apache passenger vhost"
recipe "app_passenger::install_ruby_enterprise_edition", "Install Ruby EE"
recipe "app_passenger::setup_db_connection", "Set up the MySQL database db.tomcat connection file."
recipe "app_passenger::do_update_code", "Update application source files from the remote repository."

recipe "app_passenger::run_custom_rails_commands", "Run specific user defined commands Commands will be executed in the app directory. Command path ../rails/bin/"



attribute "app_passenger/spawn_method",
  :display_name => "Rails spawn method",
  :description => "The  spawn method that Phusion Passenger will use.  The choices are: smart, smart-lv2, and conservative.  Ex: conservative",
  :choice => ["conservative", "smart-lv2", "smart"],
  :default => "conservative",
  :recipes => ["app_passenger::setup_apache_passenger_vhost"]

attribute "app_passenger/apache/maintenance_page",
  :display_name => "Apache maintenance page",
  :description => "Maintenance URI to show if the page exists (based on document root). Default: [document root]/system/maintenance.html.  If this file exists, your site will show a &quot;Under Maintenance&quot; page and your site will not be available.",
  :default => "",
  :recipes => ["app_passenger::setup_apache_passenger_vhost"]

attribute "app_passenger/apache/serve_local_files",
  :display_name => "Apache serve local Files",
  :description => "This option tells Apache whether it should serve the (static) content itself. Currently, it will omit PHP and TomCat dynamic content, such as *.php, *.action, *.jsp, and *.do    Ex:  true",
  :required => false,
  :default => "true",
  :recipes => ["app_passenger::setup_apache_passenger_vhost"]

attribute "app_passenger/repository/type",
  :display_name => "Repository Type",
  :description => "Choose type of Repository SVN or GIT",
  :choice => ["git", "svn"],
  :default => "git",
  :required => "optional",
  :recipes => [ "app_passenger::do_update_code" ]

attribute "app_passenger/repository/revision",
  :display_name => "Repository branch",
  :description => "Enter branch of your repo you want ot fetch  Default: HEAD ",
  :required => false,
  :default => "HEAD",
  :recipes => ["app_passenger::do_update_code"]

attribute "app_passenger/repository/url",
  :display_name => "Repository URL",
  :description => "The URL of your svn or git repository where your application code will be checked out from.  Ex: http://mysvn.net/app/ or git@github.com/whoami/project",
  :required => false,
  :recipes => ["app_passenger::do_update_code"]

attribute "app_passenger/repository/svn/username",
  :display_name => "SVN repository username",
  :description => "The SVN username that is used to checkout the application code from SVN repository.",
  :required => false,
  :default => "",
  :recipes => ["app_passenger::do_update_code"]

attribute "app_passenger/repository/svn/password",
  :display_name => "SVN repository password",
  :description => "The SVN password that is used to checkout the application code from SVN repository.",
  :required => false,
  :default => "",
  :recipes => ["app_passenger::do_update_code"]

attribute "app_passenger/repository/git/credentials",
  :display_name => "Git Repository Credentials",
  :description => "The private SSH key of the git repository.",
  :required => "optional",
  :recipes => [ "app_passenger::do_update_code" ]


attribute "app_passenger/project/environment",
  :display_name => "Rails Environment",
  :description => "Creates a Rails RAILS ENV environment variable. ",
  :default => "",
  :recipes => ["app_passenger::setup_db_connection", "app_passenger::run_custom_rails_commands"]

attribute "app_passenger/project/gem_list",
     :display_name => "Custom gems list",
     :description => "A space-separated list of optional gem(s). Format:  ruby-Gem1:version  ruby-Gem2:version ruby-Gem3 ",
     :default => "",
     :recipes => ["app_passenger::install_custom_gems"]

attribute "app_passenger/project/custom_cmd",
     :display_name => "Custom rails/bin/ command",
     :description => "A comma separated list of optional commands which will be executed in app directory. Ex: rake gems:install, rake db:create, rake get_common",
     :default => "",
     :recipes => ["app_passenger::run_custom_rails_commands"]


attribute "app_passenger/project/db/schema_name",
  :display_name => "Database schema name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up. This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :default => "",
  :recipes => ["app_passenger::setup_db_connection"]

attribute "app_passenger/project/db/adapter",
  :display_name => "Database adapter for database.yml ",
  :description => "Enter database adpter wich will be used to connect to the database Default: mysql",
  :default => "mysql",
  :recipes => ["app_passenger::setup_db_connection"]
