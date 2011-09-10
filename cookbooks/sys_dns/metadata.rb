maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures sys_dns"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe "sys_dns::default", "Installs Amazon's dnscurl.pl utility."
recipe "sys_dns::do_set_private", "Sets the dynamic DNS entry to the first private IP of the server."

attribute "sys_dns/choice",
  :display_name => "DNS Service Provider",
  :description => "The name of your DNS provider.  Select the DNS provider that you're using to manage the DNS A Records of your Master/Slave DB servers.   Ex: DNSMadeEasy, DynDNS, Route53",
  :required => "required",
  :choice => ["DNSMadeEasy", "DynDNS", "Route53"],
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]

attribute "sys_dns/id",
  :display_name => "DNS Record ID",
  :description => "The unique identifier that is associated with the DNS A Record of the Master-DB.  The unique identifier is assigned by the DNS provider when you create a dynamic DNS A Record.   This ID is used to update the associated A Record with the private IP Address of the Master-DB when defining which server is the master database.  If you are using DNSMadeEasy as your DNS provider, a 7-digit number is used.  (Ex: 4403234)",
  :required => "required",
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]

attribute "sys_dns/user",
  :display_name => "DNS User",
  :description => "The username that is used to access and modify your DNS A Records. For DNSMadeEasy and DynDNS, enter your username. (Ex: myUsername)  For AwsDNS, enter your AWS Access Key ID.  (Ex: 1JHQQ4KVEVM1JHQQ4KVE)",
  :required => "required",
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]

attribute "sys_dns/password",
  :display_name => "DNS Password",
  :description => "The password that is used to access and modify your DNS A Records. For DNSMadeEasy and DynDNS, enter your password. (Ex: myPassw0rd)  For AwsDNS, enter your AWS Secret Access Key. (Ex: XVdxPgOM4auGcMlPz61XVdxPgOM4auGcMlPz6)",
  :required => "required",
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]
