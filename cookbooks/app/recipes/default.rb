#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Setup default values for database resource
log "Provider is #{node[:app][:provider]}"
app "default" do
  persist true
  provider node[:app][:provider]
  action :nothing
end

#install required packages
app "default" do
  packages node[:app][:packages]
  action :install
end

# Let others know we are an appserver
right_link_tag "appserver:active=true"

rs_utils_marker :end
