#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "Opening database port(s) to all application servers"
db node[:db][:data_dir] do
  machine_tag "appserver:active=true"
  enable true
  action :firewall_update
end

rs_utils_marker :end
