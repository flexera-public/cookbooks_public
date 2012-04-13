maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Cookbook for a memcached server setup."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.5"


depends "rs_utils"
depends "sys_firewall"


recipe  "memcached::default",        "Default recipe for memcached setup"
recipe  "memcached::install_server", "Installation and configuration recipe for memcached"
recipe  "memcached::do_start",       "Start memcached"
recipe  "memcached::do_restart",     "Restart memcached"
recipe  "memcached::do_reload",      "Reload memcached"
recipe  "memcached::do_stop",        "Stop memcached"


attribute "memcached/port",
          :display_name => "Memcached Port",
          :description  => "",
          :required     => "recommended",
          :default      => "11211",
          :recipes      => ["memcached::install_server", "memcached::default"]

attribute "memcached/memtotal_percent",
          :display_name => "Memcached Cache size %",
          :description  => "",
          :required     => "recommended",
          :choice       => ["10", "20", "30", "40", "50", "60", "70", "80", "90"],
          :default      => "90",    #using str for further conversion to int
          :recipes      => ["memcached::install_server"]

attribute "memcached/extra_options",
          :display_name => "Memcached extra options",
          :description  => "",
          :required     => "optional",
          :default      => "",
          :recipes      => ["memcached::install_server"]

attribute "memcached/user",
          :display_name => "Memcached user",
          :description  => "",
          :required     => "recommended",
          :default      => "nobody",
          :recipes      => ["memcached::install_server"]

attribute "memcached/connection_limit",
          :display_name => "Memcached connection limit",
          :description  => "",
          :required     => "recommended",
          :default      => "1024",
          :recipes      => ["memcached::install_server"]

# TO DO set_unless[:memcached][:ip] = ""

attribute "memcached/log_level",
          :display_name => "Memcached logging output level",
          :description  => """ (off), -v (verbose) -vv (debug)  -vvv (extremely verbose)",
          :required     => "recommended",
          :choice       => ["", "-v", "-vv", "-vvv"],
          :default      => "",
          :recipes      => ["memcached::install_server"]

# TO DO set_unless[:memcached][:threads] = node[:cpu].count

attribute "memcached/threads",
          :display_name => "Memcached cpu threads",
          :description  => "",
          :required     => "recommended",
          :default      => "1",
          :recipes      => ["memcached::install_server"]

attribute "memcached/cluster_id",
          :display_name => "Memcached cluster_id",
          :description  => "",
          :required     => "recommended",
          :default      => "cache_cluster",
          :recipes      => ["memcached::install_server", "memcached::default"]
