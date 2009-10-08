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
  :description => "The email address that Apache uses to send administrative mail (set in /etc/httpd/conf/httpd.conf).  By setting it to root@localhost.com emails are saved on the server.  You can use your own email address, but your spam filters might block them because reverse DNS lookup will show a mismatch between EC2 and your domain.",
  :default => "root@localhost"

attribute "web_apache/mpm",
  :display_name => "Multi-Processing Module",
  :description => "Can be set to 'worker' or 'prefork' and defines the setting in httpd.conf.  Use 'worker' for Rails/Tomcat/Standalone frontends and 'prefork' for PHP.",
  :multiple_values => true,
  :default => [ "worker", "prefork" ]

