maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
#license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs the tomcat application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.1"

depends "app"
depends "db_mysql"
depends "repo_git"
depends "rs_utils"

recipe  "app_tomcat::default", "Installs the tomcat application server."
recipe  "app_tomcat::do_update_code", "Update application source files from the remote repository."
recipe  "app_tomcat::setup_db_connection", "Set up the MySQL database db.tomcat connection file."
recipe  "app_tomcat::setup_tomcat_configs", "Configure tomcat."
recipe  "app_tomcat::setup_monitoring", "Install collectd monitoring for tomcat."
recipe  "app_tomcat::setup_mod_jk_vhost", "Installs, configures mod_jk and creates vhost."
attribute "tomcat",
  :display_name => "Tomcat Application Settings",
  :type => "hash"
#
# optional attributes
#
attribute "tomcat/db_name",
  :display_name => "Database Name",
  :description => "Enter the name of the MySQL database to use. Ex: mydatabase",
  :required => "required",
  :recipes => [ "app_tomcat::setup_db_connection"  ]

attribute "tomcat/code",
  :display_name => "Tomcat Application Code",
  :type => "hash"

attribute "tomcat/java",
  :display_name => "Tomcat java settings",
  :type => "hash"

#Code repo attributes

attribute "tomcat/code/root_war",
  :display_name => "War file for ROOT",
  :description => "The name of the war file to be renamed to ROOT.war. Ex: myapplication.war",
  :required => "optional",
  :recipes => [ "app_tomcat::do_update_code" ]


attribute "tomcat/code/perform_action",
  :display_name => "Type of repo pull",
  :description => "Choose the pull action which will be performed, 'pull'- standard repo pull, 'capistrano_pull' standard pull and then capistrano  .",
  :choice => ["pull", "capistrano_pull"],
  :default => "pull",
  :recipes => [ "app_tomcat::do_update_code" ]

#Java tuning parameters
attribute "tomcat/java/xms",
  :display_name => "Tomcat Java XMS",
  :description => "The java Xms argument (i.e. 512m)",
  :required => "optional",
  :recipes => [ "app_tomcat::setup_tomcat_configs" ]

attribute "tomcat/java/xmx",
  :display_name => "Tomcat Java XMX",
  :description => "The java Xmx argument (i.e. 512m)",
  :required => "optional",
  :recipes => [ "app_tomcat::setup_tomcat_configs" ]

attribute "tomcat/java/PermSize",
  :display_name => "Tomcat Java PermSize",
  :description => "The java PermSize argument (i.e. 256m)",
  :required => "optional",
  :recipes => [ "app_tomcat::setup_tomcat_configs" ]

attribute "tomcat/java/MaxPermSize",
  :display_name => "Tomcat Java MaxPermSize",
  :description => "The java MaxPermSize argument (i.e. 256m)",
  :required => "optional",
  :recipes => [ "app_tomcat::setup_tomcat_configs" ]

attribute "tomcat/java/NewSize",
  :display_name => "Tomcat Java NewSize",
  :description => "The java NewSize argument (i.e. 256m)",
  :required => "optional",
  :recipes => [ "app_tomcat::setup_tomcat_configs" ]

attribute "tomcat/java/MaxNewSize",
  :display_name => "Tomcat Java MaxNewSize",
  :description => "The java MaxNewSize argument (i.e. 256m)",
  :required => "optional",
  :recipes => [ "app_tomcat::setup_tomcat_configs" ]
