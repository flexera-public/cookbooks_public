maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs the tomcat application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2.1"

depends "app"
depends "db_mysql"
depends "db_postgres"
depends "repo"
depends "rs_utils"

recipe  "app_tomcat::default", "Installs the tomcat application server."

# optional attributes
attribute "tomcat/db_name",
  :display_name => "Database Name",
  :description => "Enter the name of the MySQL database to use. Ex: mydatabase",
  :required => "required"


#Code repo attributes
attribute "tomcat/code/root_war",
  :display_name => "War file for ROOT",
  :description => "The path to the war file relative to project repo root directory. Will be renamed to ROOT.war. Ex: /dist/app_test.war",
  :required => "recommended",
  :default => ""

#Java tuning parameters
attribute "tomcat/java/xms",
  :display_name => "Tomcat Java XMS",
  :description => "The java Xms argument (i.e. 512m)",
  :required => "optional",
  :default => "512m"

attribute "tomcat/java/xmx",
  :display_name => "Tomcat Java XMX",
  :description => "The java Xmx argument (i.e. 512m)",
  :required => "optional",
  :default => "512m"

attribute "tomcat/java/PermSize",
  :display_name => "Tomcat Java PermSize",
  :description => "The java PermSize argument (i.e. 256m)",
  :required => "optional",
  :default => "256m"

attribute "tomcat/java/MaxPermSize",
  :display_name => "Tomcat Java MaxPermSize",
  :description => "The java MaxPermSize argument (i.e. 256m)",
  :required => "optional",
  :default => "256m"

attribute "tomcat/java/NewSize",
  :display_name => "Tomcat Java NewSize",
  :description => "The java NewSize argument (i.e. 256m)",
  :required => "optional",
  :default => "256m"

attribute "tomcat/java/MaxNewSize",
  :display_name => "Tomcat Java MaxNewSize",
  :description => "The java MaxNewSize argument (i.e. 256m)",
  :required => "optional",
  :default => "256m"

attribute "tomcat/db_adapter",
  :display_name => "Database adapter for application ",
  :description => "Enter database adpter wich will be used to connect to the database Default: postgresql",
  :default => "mysql",
  :choice => [ "mysql", "postgresql" ],
  :recipes => ["app_tomcat::default"]
