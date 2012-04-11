maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Cookbook for a memcached server setup."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rs_utils"




recipe  "memcached::default", "Default recipe for memcached setup"
recipe  "memcached::install_server", "Installation and configuration recipe for memcached"

#set_unless[:memcached][:port] = 11211
attribute "memcached/port",
  :display_name => "Memcached Port",
  :description => "",
  :required => "recommended",
  :default => "11211"

#set_unless[:memcached][:memtotal_percent] = 90
attribute "memcached/memtotal_percent",
  :display_name => "Memcached Cache size %",
  :description => "",
  :required => "recommended",
  :default => "90"

#set_unless[:memcached][:ip] =

#set_unless[:memcached][:user] = "nobody"

#set_unless[:memcached][:user] = "nobody"

#set_unless[:memcached][:connection_limit] = 1024

#set_unless[:memcached][:threads] = "nobody"

#set_unless[:memcached][:log_level] = "" # off, -v (verbose) -vv (debug)

# Calculated options
#set_unless[:memcached][:threads] = node[:cpu].count
