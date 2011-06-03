# Cookbook Name:: rs_utils
# Recipe:: monitoring
#
# Copyright (c) 2010 RightScale Inc
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

# These are not conditional assignments, but array joins..  Maybe a different syntax would be a good idea to avoid confusion?
node[:rs_utils][:plugin_list_ary] = node[:rs_utils][:plugin_list].split | node[:rs_utils][:plugin_list_ary]
node[:rs_utils][:process_list_ary] = node[:rs_utils][:process_list].split | node[:rs_utils][:process_list_ary]

log "Configure collectd"

package "collectd"

# Use collectdmon for CentOS
if node.platform == 'centos'
  remote_file "/etc/init.d/collectd" do
    source "collectd-init-centos-with-monitor"
    mode 0755
  end
end

service "collectd" do
  action :enable
end

if node.platform == "ubuntu"
  log "Perform Ubuntu Specific collectd install..."
  package "liboping0" 

  if node.platform_version != "8.04"
    # Symlink if in the share dir
    link ::File.join(node.rs_utils.collectd_lib, 'types.db') do
      to "/usr/share/collectd/types.db"
      notifies :restart, resources(:service => "collectd")
    end
    
    # Otherwise add it from cookbook
    remote_file ::File.join(node.rs_utils.collectd_lib, 'types.db') do 
      not_if { ::File.exists?(::File.join(node.rs_utils.collectd_lib, 'types.db')) }
      source "karmic_types.db"
    end
  end  
elsif node.platform == "debian"
  log "Debian detected; installing types.db from /usr/share."
  # Symlink if in the share dir
  link ::File.join(node.rs_utils.collectd_lib, 'types.db') do
    to "/usr/share/collectd/types.db"
    notifies :restart, resources(:service => "collectd")
  end
end

directory node.rs_utils.collectd_plugin_dir do
  recursive true
end

template node.rs_utils.collectd_config do
  backup false
  source "collectd.config.erb"
  notifies :restart, resources(:service => "collectd")
end

# Configure process monitoring
template File.join(node.rs_utils.collectd_plugin_dir, 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

right_link_tag "rs_monitoring:state=active"
