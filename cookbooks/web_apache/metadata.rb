maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures the apache2 webserver"
version          "0.0.1"

depends "apache2"

attribute "web_apache",
  :display_name => "apache hash",
  :description => "Apache Web Server",
  :type => "hash"
  
attribute "web_apache/contact",
  :display_name => "contact email ",
  :description => "contact email address for web admin",
  :default => "root@localhost"

attribute "web_apache/mpm",
  :display_name => "Multi-Processing Module",
  :description => "setting for MPM, ",
  :multiple_values => true,
  :default => [ "worker", "prefork" ]

