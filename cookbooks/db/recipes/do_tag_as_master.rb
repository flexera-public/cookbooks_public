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

rs_utils_marker :begin

# == Set master DNS
# Do this first so that DNS can propagate while the recipe runs
#
include_recipe "db::setup_master_dns"

# == Set master tags
# Tag the server with the master tags rs_dbrepl:master_active 
# and rs_dbrepl:master_instance_uuid
#
active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}"
log "Tagging server with #{active_tag}"
right_link_tag active_tag

unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "Tagging server with #{unique_tag}"
right_link_tag unique_tag

# == Set master node variables
#
ruby_block "initialize master state" do 
  block do 
    node[:db][:current_master_uuid] = node[:rightscale][:instance_uuid]
    node[:db][:current_master_ip] = node[:cloud][:private_ips][0]
    node[:db][:this_is_master] = true
  end
end

rs_utils_marker :end
