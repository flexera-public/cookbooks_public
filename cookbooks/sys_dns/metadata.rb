maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures sys_dns"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe "sys_dns::default", "Installs Amazon dnscurl.pl utility."
recipe "sys_dns::do_set_private", "Sets the dynamic DNS entry to the first private IP of the server."

attribute "sys_dns/choice",
  :display_name => "DNS Service Provider",
  :description => "TODO",
  :required => "required",
  :choice => ["DNSMadeEasy", "DynDNS", "Route53"]

attribute "sys_dns/id",
  :display_name => "Dynamic Record ID",
  :description => "TODO",
  :required => "required"

attribute "sys_dns/user",
  :display_name => "User",
  :description => "TODO",
  :required => "required"

attribute "sys_dns/password",
  :display_name => "Password",
  :description => "TODO",
  :required => "required"
