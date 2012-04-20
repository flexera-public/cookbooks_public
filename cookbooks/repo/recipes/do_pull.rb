#
# Cookbook Name:: repo
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

if ( node[:repo][:default][:destination]== "") then
  node[:repo][:default][:destination]= "/tmp/repo"
  log "you did not enter destination, so repo will be pulled to /tmp/repo"
end

repo "default" do
  destination                 node[:repo][:default][:destination]
  action                      node[:repo][:default][:perform_action]
end

rs_utils_marker :end
