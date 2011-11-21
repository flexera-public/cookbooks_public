# Cookbook Name:: rs_utils
# Recipe:: install_tools
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

rs_utils_marker :begin

SANDBOX_BIN_DIR = "/opt/rightscale/sandbox/bin"
RS_TOOL_VERSION = "0.4.23"
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
