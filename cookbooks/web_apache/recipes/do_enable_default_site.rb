#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

service "apache2" do
  action :nothing
end

# disable default vhost
log 'Enabling deafult vhost'
apache_site "default" do
  enable true
  notifies :reload, resources(:service => "apache2")
end

rs_utils_marker :end
