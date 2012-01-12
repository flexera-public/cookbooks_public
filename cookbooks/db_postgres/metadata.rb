maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures a PostgreSQL database server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "sys_dns"
depends "db"
depends "rs_utils"
depends "block_device"

recipe  "db_postgres::default", "Runs the client 'db::install_client' recipes."
recipe  "db_postgres::setup_pgmaster", "Runs the client 'db_postgres::setup_pgmaster' recipe to setup master config for replication"

attribute "db_postgres",
  :display_name => "General Database Options",
  :type => "hash"
  
# == Default attributes
#
attribute "db_postgres/server_usage",
  :display_name => "Server Usage",
  :description => "Use 'dedicated' if the postgresql config file allocates all existing resources of the machine.  Use 'shared' if the PostgreSQL config file is configured to use less resources so that it can be run concurrently with other apps like Apache and Rails for example.",
  :recipes => [
    "db_postgres::default"
  ],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"

attribute "db_postgres/slave/sync",
  :display_name => "Slave Sync State",
  :description => "Enables/Disables Slave sync state with Master, if enable slave connect with master in 'sync' state, otherwise in 'async' state. To check the state of slave, run query 'select application_name,state,sync_priority,sync_state from pg_stat_replication;' on master.",
  :choice => ["enable", "disable"],
  :default => "disable",
  :recipes => [ "db_postgres::setup_pgmaster" ]
