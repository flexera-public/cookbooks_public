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
recipe  "db_postgres::do_set_slave_sync_mode", "Set master to do sync based replication with slave"
recipe  "db_postgres::do_set_slave_async_mode", "Set master to do async based replication with slave"
recipe  "db_postgres::do_show_slave_sync_mode", "Show the sync mode for the replication"

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

attribute "db_postgres/database_name",
  :display_name => "Database Name",
  :description => "Enter the name of the PostgreSQL database for setting up postgresql database monitoring. Ex: mydbname",
  :required => true,
  :recipes => [ "db_postgres::default"]
