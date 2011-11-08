# Cookbook Name:: rs_utils
# Recipe:: monitoring
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

# These are not conditional assignments, but array joins..  Maybe a different syntax would be a good idea to avoid confusion?
node[:rs_utils][:plugin_list_ary] = node[:rs_utils][:plugin_list].split | node[:rs_utils][:plugin_list_ary]
node[:rs_utils][:process_list_ary] = node[:rs_utils][:process_list].split | node[:rs_utils][:process_list_ary]

# == Install Attached Packages 
#
# Installs collectd packages that are matched to the RightScale monitoring
# system.  These packages are locked/pinned to avoid accidental update.
#
# TODO: move these packages into RightScale specific mirror to improve
#       cookbook download time.
#
package "librrd4" if node[:platform] == 'ubuntu'

arch = (node[:kernel][:machine] == "x86_64") ? "64" : "i386"
type = (node[:platform] == 'ubuntu') ? "deb" : "rpm"
installed_ver = (node[:platform] =~ /redhat|centos/) ? `rpm -q --queryformat %{VERSION} collectd`.strip : `dpkg-query --showformat='${Version}' -W collectd`.strip 
installed = (installed_ver == "") ? false : true
log 'Collectd package not installed' unless installed
log "Checking installed collectd version: installed #{installed_ver}" if installed

# Remove existing version of collectd

# dpkg will remove the older package if it is a different version so do not need to worry about it.
# This will break if centos releases a newer version of collectd and repos are not frozen to the CR date.
# Upgrade for rpm does not seem to work so using two step - removal and install.
package "collectd" do
  only_if { type == "rpm" && installed && ! installed_ver =~ /4\.10\.0.*$/ }
  action :remove
end

# Find and install local packages
packages = ::File.join(::File.dirname(__FILE__), "..", "files", "packages", "*#{arch}.#{type}")
Dir.glob(packages).each do |p|
  package p do
    not_if { type == "deb" }
    source p
    action :install
  end
  # Using dpkg because apt resource does not handle local deb files correctly.
  dpkg_package p do
    only_if { type == "deb" }
    source p
    options "--ignore-depends=libcollectdclient0 --ignore-depends=collectd-core"
    action :install
  end
end

# If APT, pin this package version so it can't be updated.
remote_file "/etc/apt/preferences.d/00rightscale" do
  only_if { node[:platform] == "ubuntu" }
  source "apt.preferences.rightscale"
end

# If YUM, lock this collectd package so it can't be updated
if node[:platform] =~ /redhat|centos/
  lockfile = "/etc/yum.repos.d/Epel.repo"
  bash "Lock package - YUM" do
    only_if { `grep -c 'exclude=collectd' /etc/yum.repos.d/Epel.repo`.strip == "0" }
    code <<-EOF
      echo -e "\n# Do not allow collectd version to be modified.\nexclude=collectd\n" >> #{lockfile}
    EOF
  end
end

# Enable service on system restart
service "collectd" do
  action :enable
end


# == Generate config file 
#
# This should be updated to use the default config file installed
# with the package.  The default configs should be template-ized as needed.
template node[:rs_utils][:collectd_config] do
  backup 5
  source "collectd.config.erb"
  notifies :restart, resources(:service => "collectd")
end

# == Create plugin conf dir
#
directory "#{node[:rs_utils][:collectd_plugin_dir]}" do
  owner "root"
  group "root"
  recursive true
  action :create
end
# == Install a Nightly Crontask to Restart Collectd 
#
# Add the task to /etc/crontab, at 04:00 localtime.
cron "collectd" do
  command "service collectd restart > /dev/null"
  minute "00"
  hour   "4"
end

# == Monitor Processes from Script Input 
#
# Write the process file into the include directory from template.
template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

# Patch collectd init script, so it uses collectdmon.  
# Only needed for CentOS, Ubuntu already does this out of the box.
if node[:platform] =~ /redhat|centos/
  remote_file "/etc/init.d/collectd" do
    source "collectd-init-centos-with-monitor"
    mode 0755
    notifies :restart, resources(:service => "collectd")
  end
end

# == Tag required to enable monitoring
#
right_link_tag "rs_monitoring:state=active" 

# == Start monitoring
#
service "collectd" do
  action :start
end

log "RightScale monitoring setup complete."

rs_utils_marker :end
