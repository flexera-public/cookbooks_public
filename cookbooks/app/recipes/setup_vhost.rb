#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Configuring vhost file for App server"
app "default" do
  root node[:app][:root]
  port node[:app][:port].to_i
  action :setup_vhost
  persist true
end

rs_utils_marker :end
