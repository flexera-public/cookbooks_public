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

define :rs_utils_firewall_rule, :ip_addr => nil, :enable => true do
  port = params[:port] ? params[:port] : params[:name]
  ip_addr = params[:ip_addr] 
  to_enable = params[:enable]

  # Tell user what is going on
  msg = "#{to_enable ? "Enabling" : "Disabling"} firewall rule for port #{port}"
  msg << " only for #{ip_addr}" if ip_addr
  msg << " for everyone!" unless ip_addr
  log msg

  include_recipe "iptables::default"
  
  # Use iptables cookbook with our template to create rule
  rule = "port_#{port}"
  rule << "_#{ip_addr}" if ip_addr
  iptables_rule rule do
    source "iptables_port.erb"
    cookbook "rs_utils"
    variables ({ 
      :port => port,
      :ip_addr => ip_addr })
    enable to_enable
  end 
  
end
