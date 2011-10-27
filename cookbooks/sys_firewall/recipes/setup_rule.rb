# Cookbook Name:: sys_firewall
# Recipe:: setup_rule
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

# convert inputs into parameters usable by the firewall_rule definition
# TODO add support for 'any' and port ranges '80,8000,3000-4000'
rule_port = node[:sys_firewall][:rule][:port].to_i
raise "Invalid port specified: #{node[:sys_firewall][:rule][:port]}.  Valid range 1-65536" unless rule_port > 0 and rule_port <= 65536
rule_ip = node[:sys_firewall][:rule][:ip_address]
rule_ip = (rule_ip == "" || rule_ip.downcase =~ /any/ ) ? nil : rule_ip 
rule_protocol = node[:sys_firewall][:rule][:protocol]
to_enable = (node[:sys_firewall][:rule][:enable] == "enable") ? true : false

if node[:sys_firewall][:enabled] == "enabled"

  sys_firewall rule_port do
    ip_addr rule_ip
    protocol rule_protocol
    enable to_enable
    action :update
  end

else 
  log "Firewall not enabled. Not adding rule for #{rule_port}."
end

rs_utils_marker :end
