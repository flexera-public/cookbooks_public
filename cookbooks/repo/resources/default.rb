#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

actions :pull

attribute :url, :required => true
attribute :branch, :default => "master"
attribute :dest, :default => "." 
attribute :cred
  
  
