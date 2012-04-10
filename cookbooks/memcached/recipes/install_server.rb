#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Installing memcached package..."
package "memcached" do
  action :install
end
log "  memcached package successfully installed!"

rs_utils_marker :end