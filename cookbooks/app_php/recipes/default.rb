#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

#TODO Code Cleanup
log "default empty recipe for attributes initialization"


=begin
# == Install user-specified Packages and Modules
#
[ node[:php][:package_dependencies] | node[:php][:modules_list] ].flatten.each do |p|
  package p
end

node[:php][:module_dependencies].each do |mod|
  apache_module mod
end
=end
rs_utils_marker :end
