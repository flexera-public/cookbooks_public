maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Cookbook for a memcached server setup."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.6"


depends "rs_utils"
depends "sys_firewall"
depends "logrotate"


recipe  "memcached::default",        "Default recipe for memcached setup"
recipe  "memcached::install_server", "Installation and configuration recipe for memcached"
recipe  "memcached::do_start",       "Start memcached"
recipe  "memcached::do_restart",     "Restart memcached"
recipe  "memcached::do_reload",      "Reload memcached"
recipe  "memcached::do_stop",        "Stop memcached"


attribute "memcached/tcp_port",
          :display_name => "Memcached TCP Port",
          :description  => "TCP port number to listen on.",
          :required     => "recommended",
          :default      => "11211",
          :recipes      => ["memcached::install_server", "memcached::default"]

attribute "memcached/udp_port",
          :display_name => "Memcached UDP Port",
          :description  => "UDP port number to listen on.",
          :required     => "recommended",
          :default      => "11211",
          :recipes      => ["memcached::install_server", "memcached::default"]

attribute "memcached/user",
          :display_name => "Memcached user",
          :description  => "",
          :required     => "recommended",
          :default      => "nobody",
          :recipes      => ["memcached::install_server"]

attribute "memcached/connection_limit",
          :display_name => "Memcached connection limit",
          :description  => "Number of simultaneous connections.",
          :required     => "recommended",
          :default      => "1024",
          :recipes      => ["memcached::install_server"]

attribute "memcached/memtotal_percent",
          :display_name => "Memcached Cache size %",
          :description  => "Max memory to use for items.",
          :required     => "recommended",
          :choice       => ["10", "20", "30", "40", "50", "60", "70", "80", "90"],
          :default      => "90",    #using str for further conversion to int
          :recipes      => ["memcached::install_server"]

attribute "memcached/threads",
          :display_name => "Memcached used threads",
          :description  => "Use a number from 1 to <maximum number of threads for the instance>.",
          :required     => "recommended",
          :default      => "1",
          :recipes      => ["memcached::install_server"]

attribute "memcached/ip",
          :display_name => "Memcached listening ip",
          :description  => "Interface to listen on. This parameter is one of the only security measures that memcached has, so make sure it's listening on a firewalled interface.",
          :required     => "recommended",
          :choice       => ["localhost", "private", "public", "any"],
          :default      => "any",
          :recipes      => ["memcached::install_server"]

attribute "memcached/log_level",
          :display_name => "Memcached logging output level",
          :description  => """ (off), -v (verbose) -vv (debug)  -vvv (extremely verbose)",
          :required     => "recommended",
          :choice       => ["", "-v", "-vv", "-vvv"],
          :default      => "",
          :recipes      => ["memcached::install_server"]

attribute "memcached/cluster_id",
          :display_name => "Memcached cluster_id",
          :description  => "",
          :required     => "recommended",
          :default      => "cache_cluster",
          :recipes      => ["memcached::install_server", "memcached::default"]
