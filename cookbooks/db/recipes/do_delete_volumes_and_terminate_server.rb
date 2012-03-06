# Cookbook Name:: db
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

# Detach and delete volumes and then terminate the server.
# This recipe ensures that the volume is deleted prior to the instance
# being terminated
#
rs_utils_marker :begin

raise "Server terminate safety not off.  Override db/terminate_safety to run this recipe" unless node[:db][:terminate_safety] == "off"

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

DATA_DIR = node[:db][:data_dir]
NICKNAME = get_device_or_default(node, :device1, :nickname)

log "  Resetting the database..."
db DATA_DIR do
  action :reset
end

log "  Detach and delete volume..."
block_device NICKNAME do
  action :reset
end

rs_shutdown "Terminate the server now" do
  # And shutdown regardless of any errors.
  immediately true
  action :terminate
end

rs_utils_marker :end
