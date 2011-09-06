# Cookbook Name:: setup_server_tags
# Recipe:: default
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

# RightScale unique identifier
uuid = node[:rightscale][:instance_uuid]
log "Adding server tag for UUID #{uuid}"
right_link_tag "server:uuid=#{uuid}"

i=0
# Add a tag for each private IP address
while node[:cloud][:private_ips] && node[:cloud][:private_ips][i] do 
  ip = node[:cloud][:private_ips][i]
  log "Adding private ip tag for ip address #{ip}"
  right_link_tag "server:private_ip_#{i}=#{ip}"
  i += 1
end

i=0
# Add a tag for each public IP address
while node[:cloud][:public_ips] && node[:cloud][:public_ips][i] do 
  ip = node[:cloud][:public_ips][i]
  log "Adding public ip tag for ip address #{ip}"
  right_link_tag "server:public_ip_#{i}=#{ip}"
  i += 1
end

rs_utils_marker :end
