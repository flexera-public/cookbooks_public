maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RightScale Cookbooks"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
 
recipe "rightscale::default"
 
# == RightScale ENV attributes.
#
# Maps each env:RS_* input  a node[:rightscale][] equivalent.
# DO NOT CHANGE THESE inputs unless you know what you are doing.
# Doing so may break dashboard monitoring and cookbook recipes.
attribute "rightscale",
  :display_name => "RightScale Attributes",
  :type => "hash"
  
# Set them as optional so they are hidden, create a single choice and set the default value
# 
attribute "rightscale/instance_uuid",
  :display_name => "Instance UUID",
  :description => "A value of 'env:RS_INSTANCE_UUID' is required for proper RightScale monitoring and logging.",
  :required => "optional",
  :choice => [ "env:RS_INSTANCE_UUID" ],
  :default => "env:RS_INSTANCE_UUID",
  :recipes => [ "rightscale::default" ]
attribute "rightscale/servers/sketchy/hostname",
  :display_name => "Sketchy Server",
  :description => "A value of 'env:RS_SKETCHY' is required to use RightScale monitoring servers.",
  :required => "optional",
  :choice => [ "env:RS_SKETCHY" ],
  :default => "env:RS_SKETCHY",
  :recipes => [ "rightscale::default" ]

