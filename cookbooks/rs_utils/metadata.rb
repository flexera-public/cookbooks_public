maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs common utilities used by RightScale instances."
version          "0.0.1"

recipe "rs_utils::install_mysql_collectd_plugin", "Install mysql collectd plugin"
recipe "rs_utils::install_utils", "Install utilities"
recipe "rs_utils::install_file_stats_collectd_plugin", "Install file-stats.rb collectd plugin.  This is used for mysql binary backup alerting."
#
# optional
#
attribute "rs_utils/timezone",
  :display_name => "Timezone",
  :description => "Sets the system time to the timezone of the specified input, which must be a valid zoneinfo/tz database entry.  If the input is 'unset' the timezone will use the 'localtime' that's defined in your RightScale account under Settings -> User -> Preferences tab.  You can find a list of valid examples from the timezone pulldown bar in the Preferences tab. The server will not be updated for daylight savings time.  Ex: US/Pacific, US/Eastern",
  :required => false,
  :default => "UTC",
  :recipes => [ "rs_utils::install_utils", "rs_utils::default" ]
  
attribute "rs_utils/process_list",
  :display_name => "Process List",
  :description => "A optional list of additional processes to monitor in the RightScale Dashboard.  Ex: sshd crond",
  :required => false,
  :default => "",
  :recipes => [ "rs_utils::install_mysql_collectd_plugin", "rs_utils::install_utils", "rs_utils::default" ]

attribute "rs_utils/private_ssh_key",
  :display_name => "Private SSH Key",
  :description => "The private SSH key of another instance that gets installed on this instance.  It allows this instance to SSH into another instance to update the configuration files. Select input type 'key' from the dropdown and then select an SSH key that is installed on the other instance.",
  :required => false,
  :default => "",
  :recipes => [ "rs_utils::install_utils", "rs_utils::default" ]
