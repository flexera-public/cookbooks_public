#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Provider is #{node[:app][:provider]}"
log "  Installing #{node[:app][:packages]}" if node[:app][:packages]

# Setup default values for database resource and install required packages
app "default" do
  persist true
  provider node[:app][:provider]
  packages node[:app][:packages]
  action :install
end


# Let others know we are an appserver
right_link_tag "appserver:active=true"

rs_utils_marker :end
