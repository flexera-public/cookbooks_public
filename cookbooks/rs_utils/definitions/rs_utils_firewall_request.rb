# Copyright (c) 2011 RightScale, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

define :rs_utils_firewall_request, :machine_tag => nil, :enable => true, :ip_addr => nil, :port => nil do

  port = params[:port] ? params[:port] : params[:name]
  ip_addr = params[:ip_addr] 
  to_enable = params[:enable]
  tag = params[:machine_tag]

  # Tell user what is going on
  msg = "Requesting port #{port} be #{to_enable ? "opened" : "closed"}"
  msg << " only for #{ip_addr}" if ip_addr
  msg << " for everyone" unless ip_addr
  msg << " on servers with tag: #{tag}"
  log msg
  
  # Setup attributes
  attrs = {:rs_utils => {:firewall => {:rule => Hash.new}}}
  attrs[:rs_utils][:firewall][:rule][:port] = port
  attrs[:rs_utils][:firewall][:rule][:enable] = to_enable.to_s # recipe expects a string
  attrs[:rs_utils][:firewall][:rule][:ip_address] = ip_addr
  
  # Use RightNet to update firewall rules on all tagged servers
  remote_recipe "Request firewall update" do
    recipe "rs_utils::setup_firewall_rule"
    recipients_tags tag
    attributes attrs
  end 
  
end
