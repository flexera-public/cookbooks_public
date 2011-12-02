#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

if node[:web_apache][:ssl_enable] == "true"
  Chef::Log.info "Enabling SSL"
  include_recipe "web_apache::setup_frontend_ssl_vhost"
else
  Chef::Log.info "Using regular HTTP"
  include_recipe "web_apache::setup_frontend_http_vhost"
end

rs_utils_marker :end
