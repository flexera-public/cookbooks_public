#
# Cookbook Name:: repo
# Recipe:: do_pull
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


repo "default" do
  destination                 node[:repo][:default][:destination]
  action                      node[:repo][:default][:perform_action]
end

rs_utils_marker :end


