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
#   Do this first so that DNS can propagate while waiting for tags to show up
#
include_recipe "db::setup_master_dns"

# == Set master tags
#   tag the server with the master tags rs_dbrepl:master_active and rs_dbrepl:master_instance_uuid
#
active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}"
log "Tagging server with #{active_tag}"
right_link_tag active_tag

unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "Tagging server with #{unique_tag}"
right_link_tag unique_tag

# == Wait for tags
#   Tags are not instantly available - need to wait for them.
#
log "Waiting for tags to exist..."
rs_utils_server_collection "wait_for_master_servers" do
  tags [active_tag, unique_tag]
  empty_ok false
end

# == Sleep hoping tags will show up
#   There is no deterministic way to check if a tag has propagated to all servers.
#   This sleep is an attempt give enough time for the tags to become "consistent".
#
#TODO make sure this is the best way to sleep
#TODO can we check DNS - we know that will be ready in TTL (60 seconds) and then wait
# until the tags match what good old relliable DNS says
bash "sleep waiting for tags to be really there" do
  code <<-EOH
  sleep 60
  EOH
end

# == Double check tags
#   The tag service will give a differnet answer depending on what server filled
#   the request.  You never really know if all tag servers are going to return
#   the same information.
#   With the sleep the hope is that the tag is available.  This check will give a
#   clear error message if the tag has not propagated.
#   HOWEVER - this only tells you that two servers agree.  Which is a weak quroam
#   when you have 10's of servers spread all over the world.
#   And 60 seconds is a guess - it could be an hour before things become consistent.
#   Deal with it.
#

include_recipe 'db::do_lookup_master'
raise "Inconsistent tags" unless node[:db][:this_is_master]

rs_utils_marker :end
