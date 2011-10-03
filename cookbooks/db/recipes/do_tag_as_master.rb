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

active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}"
log "Tagging server with #{active_tag}"
right_link_tag active_tag

unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "Tagging server with #{unique_tag}"
right_link_tag unique_tag

log "Waiting for tags to exist..."
COLLECTION_NAME = "master_servers"
wait_for_tag active_tag do
  collection_name COLLECTION_NAME
end

wait_for_tag unique_tag do
  collection_name COLLECTION_NAME
end

include_recipe "db::setup_master_dns"

rs_utils_marker :end
