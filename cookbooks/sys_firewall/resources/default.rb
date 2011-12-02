#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

actions :update, :update_request

attribute :port, :kind_of => Integer # Can also be passed as resource name
attribute :protocol, :equal_to => ["tcp", "udp", "all" ], :default => "tcp"
attribute :enable, :equal_to => [ true, false ], :default => true

attribute :ip_addr, :kind_of => String, :default => "any"
attribute :machine_tag, :kind_of => String, :regex => /^([^:]+):(.+)=.+/
attribute :collection, :kind_of => String, :default => "sys_firewall"

# Defines a default action
def initialize(*args)
  super
  @action = :update  
end
