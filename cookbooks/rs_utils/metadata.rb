maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Enable instance Monitoring and logging in the RightScale dashboard."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
 
recipe "rs_utils::default", "Install utilities"
recipe "rs_utils::setup_logging", "Install and configure RightScale dashboard logging."
recipe "rs_utils::setup_monitoring", "Install and configure RightScale dashboard monitoring."
recipe "rs_utils::setup_mail", "Basic mail setup."
recipe "rs_utils::setup_ssh", "Installs private ssh key."
recipe "rs_utils::setup_hostname", "Set system hostname."
recipe "rs_utils::setup_timezone", "Sets system timezone."
recipe "rs_utils::install_tools", "Install RightScale instance tools"
recipe "rs_utils::install_mysql_collectd_plugin", "Install mysql collectd plugin"
recipe "rs_utils::install_file_stats_collectd_plugin", "Install file-stats.rb collectd plugin.  This is used for mysql binary backup alerting."
recipe "rs_utils::firewall_enable", "Enables/Disables iptables firewall."
recipe "rs_utils::firewall_rule", "Enables/Disables iptables firewall rule (if firewall is enabled)."

attribute "rs_utils/firewall/enabled",  
  :display_name => "Enable Firewall",  
  :description => "Enables firewall for this server which only allows port 22 (SSH) external connections.  Use rs_utils::firewall_rule recipe to enable/disable extra ports.",
  :required => "optional",
  :default => "false",
  :recipes => [ "rs_utils::default", "rs_utils::firewall_enable", "rs_utils::firewall_rule" ]

attribute "rs_utils/firewall/rule/enable",  
  :display_name => "Enable Firewall Rule",  
  :description => "Enables/Disables a firewall rule.",
  :required => "required",
  :recipes => [ "rs_utils::firewall_rule" ]

attribute "rs_utils/firewall/rule/port",  
  :display_name => "Firewall Port",  
  :description => "Firewall port to Enables/Disable.",
  :required => "required",
  :recipes => [ "rs_utils::firewall_rule" ]

attribute "rs_utils/firewall/rule/ip_address",  
  :display_name => "Firewall IP Address",  
  :description => "Specific IP Address to enable/disable the port for. A value of 'any' allow any IP address",
  :required => "optional",
  :default => "any",
  :recipes => [ "rs_utils::firewall_rule" ]

attribute "rs_utils/timezone",
  :display_name => "Timezone",
  :description => "Sets the system time to the timezone of the specified input, which must be a valid zoneinfo/tz database entry.  If the input is 'unset' the timezone will use the 'localtime' that's defined in your RightScale account under Settings -> User -> Preferences tab.  You can find a list of valid examples from the timezone pulldown bar in the Preferences tab. The server will not be updated for daylight savings time.  Ex: US/Pacific, US/Eastern",
  :required => "optional",
  :default => "UTC",
  :recipes => [ "rs_utils::setup_timezone", "rs_utils::default" ]
  
attribute "rs_utils/process_list",
  :display_name => "Process List",
  :description => "A space-separated list of additional processes to monitor in the RightScale Dashboard.  Ex: sshd crond",
  :required => "optional",
  :default => "",
  :recipes => [ "rs_utils::install_mysql_collectd_plugin", "rs_utils::setup_monitoring", "rs_utils::default" ]

attribute "rs_utils/process_match_list",
  :display_name => "Process Match List",
  :description => "A space-separated list of pairs used to match the name(s) of additional processes to monitor in the RightScale Dashboard.  Pair arguments are passed in using the syntax 'name/regex'. Ex: ssh/ssh* cron/cron*",
  :required => "optional",
  :default => "",
  :recipes => [ "rs_utils::install_mysql_collectd_plugin", "rs_utils::setup_monitoring", "rs_utils::default" ]

attribute "rs_utils/private_ssh_key",
 :display_name => "Private SSH Key",
 :description => "The private SSH key of another instance that gets installed on this instance.  It allows this instance to SSH into another instance to update the configuration files. Select input type 'key' from the dropdown and then select an SSH key that is installed on the other instance.  Ex: key:my_key",
 :required => "optional",
 :default => "",
 :recipes => [ "rs_utils::setup_ssh" ]

attribute "rs_utils/mysql_binary_backup_file",
  :display_name => "MySQL binary file",
  :description => "An optionally specified file path for the mysql binary backup",
  :required => "optional",
  :default => "/var/run/mysql-binary-backup",
  :recipes => [ "rs_utils::install_file_stats_collectd_plugin"  ]

attribute "rs_utils/short_hostname",
  :display_name => "Short Hostname",
  :description => "The short hostname that you would like this node to have, e.g. kryten",
  :required => "required",
  :default => nil,
  :recipes => [ "rs_utils::setup_hostname" ]

attribute "rs_utils/domain_name",
  :display_name => "Domain Name",
  :description => "The domain name that you would like this node to have, e.g. domain.suf",
  :required => "optional",
  :default => "" ,
  :recipes => [ "rs_utils::setup_hostname" ]

attribute "rs_utils/search_suffix",
  :display_name => "Domain Search Suffix",
  :description => "The domain search suffix you would like this node to have, e.g. domain.suf.",
  :required => "optional",
  :default => "",
  :recipes => [ "rs_utils::setup_hostname" ]
