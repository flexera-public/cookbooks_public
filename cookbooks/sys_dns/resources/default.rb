#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

actions :set_private

attribute :id, :kind_of => String
attribute :user, :kind_of => String
attribute :password, :kind_of => String
attribute :address, :kind_of => String # TODO: , :regex => 
attribute :choice, :equal_to => [ "DNSMadeEasy", "DynDNS", "Route53" ]
