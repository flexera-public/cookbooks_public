maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs common utilities used by RightScale instances."
version          "0.0.1"

recipe "rs_utils::install_utils", "Installs basic utilities used by all RightScale instances."
recipe "rs_utils::developer_setup", "Configures instance for chef recipe development"

#
# optional
#
attribute "rs_utils/timezone",
  :display_name => "Timezone",
  :description => "Sets the server timezone. The Default value is UTC. The server will not be updated for daylight savings time.",
  :default => "UTC"
  
attribute "rs_utils/process_list",
  :display_name => "Process List",
  :description => "Adds extra processes for RightScale to monitor."

attribute "rs_utils/private_ssh_key",
  :display_name => "Private SSH Key",
  :description => "Private SSH key to install on instance."

