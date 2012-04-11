maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Cookbook for a memcached server setup."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

depends "rs_utils"
depends "sys_firewall"


recipe  "memcached::default", "Default recipe for memcached setup"
recipe  "memcached::install_server", "Installation and configuration recipe for memcached"

attribute "memcached/port",
          :display_name => "Memcached Port",
          :description => "",
          :required => "recommended",
          :default => "11211"

attribute "memcached/memtotal_percent",
          :display_name => "Memcached Cache size %",
          :description => "",
          :required => "recommended",
          :default => "90"

# TO DO set_unless[:memcached][:ip] = ""
# TO DO set_unless[:memcached][:extra_options] = ""

attribute "memcached/user",
          :display_name => "Memcached user",
          :description => "",
          :required => "recommended",
          :default => "nobody"

attribute "memcached/connection_limit",
          :display_name => "Memcached connection limit",
          :description => "",
          :required => "recommended",
          :default => "1024"

# TO DO set_unless[:memcached][:log_level] = "" # off, -v (verbose) -vv (debug)  -vvv (extremely verbose)
# TO DO set_unless[:memcached][:threads] = node[:cpu].count