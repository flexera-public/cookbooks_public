maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures RightScale system utilities."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "rs_utils"

recipe "sys::do_reconverge_list_enable", "Enable list of recipes to run every 15 minutes."
recipe "sys::do_reconverge_list_disable", "Disable recipe reconverge list."
recipe "sys::setup_swap", "Install swap space."

attribute "sys/reconverge_list",
  :display_name => "Reconverge List",
  :description => "A space-separated list of recipes to run every 15 minutes.  This is used to enforce system consistency.  Ex: app::do_firewall_request_open lb_haproxy::do_attach_all",
  :required => "optional",
  :default => "",
  :recipes => [ "sys::default", "sys::do_reconverge_list_enable", "sys::do_reconverge_list_disable" ]

attribute "sys/swap_size",
  :display_name => "Swap size in GB",
  :description => "Create and activate swap file.  Select '0' to disable swap. ex: 0.5, 1, 1.5",
  :type => "string",
  :choice => ["0","0.5","2.0"],
  :required => true,
  :recipes => [ "sys::setup_swap"]

attribute "sys/swap_file",
  :display_name => "Swapfile location",
  :description => "Location of swapfile.  Defaults to '/swapfile'.",
  :type => "string",
  :default => "/swapfile",
  :recipes => [ "sys::setup_swap"]
