maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures sys_dns"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

depends "rs_utils"

recipe "sys_dns::default", "Installs Amazon's dnscurl.pl utility."
recipe "sys_dns::do_set_private", "Sets the dynamic DNS entry to the first private IP of the server."

attribute "sys_dns/choice",
  :display_name => "DNS Service Provider",
  :description => "The name of your DNS provider. Select the DNS provider that you're using to manage the DNS A records of your master/slave database servers (e.g., DNSMadeEasy, DynDNS, Route53).",
  :required => "required",
  :choice => ["DNSMadeEasy", "DynDNS", "Route53"],
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]

attribute "sys_dns/id",
  :display_name => "DNS Record ID",
  :description => "The unique identifier that is associated with the DNS A record of the server.  The unique identifier is assigned by the DNS provider when you create a dynamic DNS A record. This ID is used to update the associated A record with the private IP address of the server when this recipe is run.  If you are using DNS Made Easy as your DNS provider, a 7-digit number is used (e.g., 4403234).",
  :required => "required",
  :recipes => ["sys_dns::do_set_private"]

attribute "sys_dns/user",
  :display_name => "DNS User",
  :description => "The user name that is used to access and modify your DNS A records. For DNS Made Easy and DynDNS, enter your user name (e.g., cred:DNS_USER). For Amazon DNS, enter your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID)",
  :required => "required",
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]

attribute "sys_dns/password",
  :display_name => "DNS Password",
  :description => "The password that is used to access and modify your DNS A Records. For DNS Made Easy and DynDNS, enter your password (e.g., cred:DNS_PASSWORD). For Amazon DNS, enter your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY)",  
  :required => "required",
  :recipes => ["sys_dns::do_set_private", "sys_dns::default"]
