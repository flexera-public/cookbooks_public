#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

SANDBOX_BIN_GEM = '/opt/rightscale/sandbox/bin/gem'
RIGHT_AWS_VERSION = '2.1.1'
RIGHT_AWS_GEM = 'right_aws'
RACKSPACE_VERSION = '0.0.0.20111110'
RACKSPACE_GEM = 'right_rackspace'
RS_TOOLS_VERSION = '1.0.33'
RS_TOOLS_GEM = 'rightscale_tools_public'
COOKBOOK_DEFAULT_GEMS = ::File.join(::File.dirname(__FILE__), '..', 'files', 'default')

r = gem_package RIGHT_AWS_GEM do
  gem_binary SANDBOX_BIN_GEM
  source "#{COOKBOOK_DEFAULT_GEMS}/#{RIGHT_AWS_GEM}-#{RIGHT_AWS_VERSION}.gem"
  action :nothing
end
r.run_action(:install)

r = gem_package RACKSPACE_GEM do
  gem_binary SANDBOX_BIN_GEM
  source "#{COOKBOOK_DEFAULT_GEMS}/#{RACKSPACE_GEM}-#{RACKSPACE_VERSION}.gem"
  action :nothing
end
r.run_action(:install)

r = gem_package RS_TOOLS_GEM do
  gem_binary SANDBOX_BIN_GEM
  source "#{COOKBOOK_DEFAULT_GEMS}/#{RS_TOOLS_GEM}-#{RS_TOOLS_VERSION}.gem"
  action :nothing
end
r.run_action(:install)

Gem.clear_paths

rs_utils_marker :end
