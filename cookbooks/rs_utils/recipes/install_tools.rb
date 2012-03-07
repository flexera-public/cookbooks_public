#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

SANDBOX_BIN_DIR = "/opt/rightscale/sandbox/bin"
RS_TOOL_VERSION = "1.0.28"
RESOURCE_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "rightscale_tools_public-#{RS_TOOL_VERSION}.gem")
RACKSPACE_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "right_rackspace-0.0.0.20111110.gem")

r = gem_package RACKSPACE_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version "0.0.0"
  action :nothing
end
r.run_action(:install)

r = gem_package RESOURCE_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version RS_TOOL_VERSION
  action :nothing
end
r.run_action(:install)

Gem.clear_paths

rs_utils_marker :end
