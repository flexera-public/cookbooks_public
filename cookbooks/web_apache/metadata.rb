maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures the apache2 webserver"
version          "0.0.1"

recipe "web_apache::default", "Runs web_apache::install_apache."
recipe "web_apache::install_apache", "Installs and configures the Apache2 webserver."
recipe "web_apache::setup_frontend", "Frontend apache vhost.  Select ssl_enabled for SSL."
recipe "web_apache::setup_frontend_ssl_vhost", "Frontend apache vhost with SSL enabled."
recipe "web_apache::setup_frontend_http_vhost", "Frontend apache vhost with SSL enabled."
recipe "web_apache::setup_monitoring", "Install collectd-apache for monitoring support"
recipe "web_apache::setup_mod_jk_vhost", "Installs, configures mod_jk and creates vhost."

all_recipes = [ "web_apache::default",  "web_apache::install_apache", "web_apache::setup_frontend_ssl_vhost", "web_apache::setup_frontend_http_vhost", "web_apache::setup_frontend"]

depends "apache2"
depends "rs_utils"

attribute "web_apache",
  :display_name => "apache hash",
  :description => "Apache Web Server",
  :type => "hash"
  
attribute "web_apache/mpm",
  :display_name => "Multi-Processing Module",
  :description => "Defines the multi-processing module setting in httpd.conf.  Use 'worker' for Rails/Tomcat/Standalone frontends and 'prefork' for PHP.",
  :recipes => all_recipes,
  :choice => [ "prefork", "worker" ],
  :default =>  "prefork"

attribute "web_apache/ssl_enable",
  :display_name => "SSL Enable",
  :description => "Enables SSL ('https')",
  :recipes => [
                "web_apache::install_apache",
                "web_apache::setup_frontend"
              ],
  :choice => [ "true", "false" ],
  :default =>  "false"

attribute "web_apache/ssl_certificate",
  :display_name => "SSL Certificate",
  :description => "SSL Certificate",
  :recipes => [ "web_apache::setup_frontend_ssl_vhost","web_apache::setup_frontend" ]

attribute "web_apache/ssl_certificate_chain",
  :display_name => "SSL Certificate Chain",
  :description => "SSL Certificate Chain",
  :recipes => [ "web_apache::setup_frontend_ssl_vhost","web_apache::setup_frontend" ]

attribute "web_apache/ssl_key",
  :display_name => "SSL Certificate Key",
  :description => "SSL Certificate Key",
  :recipes => [ "web_apache::setup_frontend_ssl_vhost","web_apache::setup_frontend" ]

attribute "web_apache/ssl_passphrase",
  :display_name => "SSL passphrase",
  :description => "SSL passphrase",
  :recipes => [ "web_apache::setup_frontend_ssl_vhost","web_apache::setup_frontend" ]

attribute "web_apache/server_name",
  :display_name => "Server Name",
  :description => "The fully qualified domain name of the application server used to define your virtual host.",
  :default => "localhost",
  :recipes => all_recipes

attribute "web_apache/application_name",
  :display_name => "Application Name",
  :description => "Sets the directory for your application's web files (/home/webapps/Application Name/current/).  If you have multiple applications, you can run the code checkout script multiple times, each with a different value for APPLICATION, so each application will be stored in a unique directory.  This must be a valid directory name.  Do not use symbols in the name.",
  :default => "myapp",
  :recipes => all_recipes
