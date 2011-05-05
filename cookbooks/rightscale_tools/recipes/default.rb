#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

SANDBOX_BIN_DIR = "/opt/rightscale/sandbox/bin"
RESOURCE_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "rightscale_tools-0.1.0.gem")
RACKSPACE_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "right_rackspace-0.0.0.gem")

r = gem_package RACKSPACE_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version "0.0.0"
  action :nothing
end
r.run_action(:install)

r = gem_package RESOURCE_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version "0.0.0"
  action :nothing
end
r.run_action(:install)

package "lvm2"
package "xfsprogs"

ruby_block "Load kernel modules" do
  block do
    `modprobe dm_mod`
    `modprobe dm_snapshot`
    `modprobe xfs`
  end
end
