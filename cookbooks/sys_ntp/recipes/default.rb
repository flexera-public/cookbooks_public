#
# Cookbook Name:: sys_ntp
# Recipe:: default
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rs_utils_marker :begin

case node[:platform]
when "ubuntu","debian"
  package "ntpdate" do
    action :install
  end
end

package "ntp" do
  action :install
end

service node[:sys_ntp][:service] do
  action :stop
end

#
# NTP doesn't always stop on Ubunut.  Make sure the process is gone
bash "kill ntp" do
  flags "-ex"
  only_if { node[:platform] == 'ubuntu' }
  code <<-EOH
    pkill -9 -f ntp || true
  EOH
end


is_xen = ::File.exist?("/proc/sys/xen")
log "  Configure Xen for independent wall clock..." if is_xen
bash "independent wallclock" do
  flags "-ex"
  only_if { is_xen }
  code <<-EOH
    echo 1 > /proc/sys/xen/independent_wallclock
  EOH
end

first_ntp_server = node[:sys_ntp][:servers].split(',')[0].strip
log "  Update time using ntpdate and ntp server #{first_ntp_server}..."
bash "update time" do
  flags "-ex"
  code <<-EOH
    # TODO retry list of servers until succeed or all fail
    ntpdate #{first_ntp_server}
  EOH
end

template "/etc/ntp.conf" do
  source "ntp.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => node[:sys_ntp][:service])
end

directory "/var/log/ntpstats" do
  owner "ntp"
  group "ntp"
  mode 0755
end

service node[:sys_ntp][:service] do
  action :start
end
rs_utils_marker :end
