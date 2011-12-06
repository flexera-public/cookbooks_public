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

attribute "tomcat/code/repo_type",
  :display_name => "Repository Type",
  :description => "Choose type of Repository: SVN or GIT",
  :choice => ["git", "svn"],
  :default => "git",
  :required => "optional",
  :recipes => [ "app_tomcat::do_update_code" ]

attribute "tomcat/code/url",
  :display_name => "Repository URL",
  :description => "Specify the URL location of the repository that contains the application code. Ex: git://github.com/mysite/myapp.git",
  :required => "required",
  :recipes => [ "app_tomcat::do_update_code", "app_tomcat::default" ]

attribute "tomcat/code/credentials",
  :display_name => "Repository Credentials",
  :description => "The private SSH key of the git repository.",
  :required => "optional",
  :recipes => [ "app_tomcat::do_update_code", "app_tomcat::default" ]

attribute "tomcat/code/svn_username",
  :display_name => "SVN username",
  :description => "The SVN username that is used to checkout the application code from SVN repository..If you use git just change value to $ignore",
  :required => "optional",
  :default => "",
  :recipes => [ "app_tomcat::do_update_code" ]

attribute "tomcat/code/svn_password",
  :display_name => "SVN password",
  :description => "The SVN password that is used to checkout the application code from SVN repository..If you use git just change value to $ignore",
  :required => "optional",
  :default => "",
  :recipes => [ "app_tomcat::do_update_code" ]

attribute "tomcat/code/branch",
  :display_name => "Repository Branch",
  :description => "The name of the branch within the git repository where the application code should be pulled from. Ex: mybranch",
  :required => "optional",
  :default => "master",
  :recipes => [ "app_tomcat::do_update_code", "app_tomcat::default" ]

attribute "tomcat/code/root_war",
  :display_name => "War file for ROOT",
  :description => "The name of the war file to be renamed to ROOT.war. Ex: myapplication.war",
  :required => "optional",
  :recipes => [ "app_tomcat::do_update_code" ]

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