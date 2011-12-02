#
# Cookbook Name:: app_rails
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

template "#{node[:rails][:code][:destination]}/config/database.yml"   do
  source "database.yaml.erb"
end

rs_utils_marker :end
