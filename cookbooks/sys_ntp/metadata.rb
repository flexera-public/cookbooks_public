maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures ntp as a client or server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"

depends "rs_utils"

recipe "sys_ntp", "Installs and configures ntp client"

%w{ ubuntu debian redhat centos fedora }.each do |os|
  supports os
end

attribute "sys_ntp/servers",
   :display_name => "NTP Servers",
   :description => "Array of servers we should talk to",
   :type => "string",
   :default => "time.rightscale.com, ec2-us-east.time.rightscale.com, ec2-us-west.time.rightscale.com"

