# Cookbook Name:: sys_firewall
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

if node[:sys_firewall][:enabled] == "enabled" 
  include_recipe "iptables"
  sys_firewall "22" # SSH
  sys_firewall "80" # HTTP
  sys_firewall "443" # HTTPS
else
  service "iptables" do
    supports :status => true 
    action [:disable, :stop]
  end
end


# == Increase connection tracking table sizes
#
# Increase the value for the 'net.ipv4.netfilter.ip_conntrack_max' parameter
# to avoid dropping packets on high-throughput systems.
#
# The ip_conntrack_max is calculated based on the RAM available on
# the VM using this formula: ip_conntrack_max=32*n, where n is the amount
# of RAM in MB. For the instance types greater or equal to 2GB, the value is
# 65536.
#
GB=1024*1024
mem_mb = node[:memory][:total].to_i/1024
conn_max = (mem_mb >= 2*GB) ? 65536 : 32*mem_mb

log "Setup IP connection tracking limit of #{conn_max}"
bash "Update net.ipv4.ip_conntrack_max" do
  only_if { node[:platform] =~ /redhat|centos/ }
  code <<-EOH 
    sysctl -e -w net.ipv4.ip_conntrack_max=#{conn_max}
  EOH
end

rs_utils_marker :end
