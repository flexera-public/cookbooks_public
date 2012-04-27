maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RightScale Cookbooks"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
 
recipe "rightscale::default", "Sets the RightScale specific attributes in the node"
 
# == RightScale ENV attributes.
#
# Maps each env:RS_* input  a node[:rightscale][] equivalent.
# DO NOT CHANGE THESE inputs unless you know what you are doing.
# Doing so may break dashboard monitoring and cookbook recipes.
attribute "rightscale",
  :display_name => "RightScale Attributes",
  :type => "hash"
  
# These inputs are set by the core site and can not be set via the metadata.  They are still valid and
# can be used the same way other node variables are set.  They are included here for documentation
# purposes.
#
# This list may change so care must be taken when adding or changing node[:rightscale] attributes.
# Only RightScale can make changes to the attributes in this cookbook and name space.

#attribute "rightscale/instance_uuid",
#  :display_name => "Instance UUID",
#  :description => "This is a place holder",
#  :required => "required",
#  :type => "env",
#  :choices => ["RS_INSTANCE_UUID"],
#  :default => "RS_INSTANCE_UUID",
#  :recipes => [ "rightscale::default" ]

#attribute "rightscale/servers/sketchy/hostname",
#  :display_name => "Sketchy Server",
#  :description => "This is a place holder",
#  :required => "required",
#  :type => "env",
#  :choices => ["RS_SKETCHY"],
#  :default => "RS_SKETCHY",
#  :recipes => [ "rightscale::default" ]

#attribute "rightscale/servers/sketchy/identifier"
#  :display_name => "Sketchy Identifier",
#  :required => "required",
#  :type => "env",
#  :choices => ["RS_INSTANCE_UUID"],
#  :default => "RS_INSTANCE_UUID",
#  :recipes => [ "rightscale::default" ]

