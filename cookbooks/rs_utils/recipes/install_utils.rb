# Cookbook Name:: rs_utils
# Recipe:: install_utils
#
# Copyright (c) 2009 RightScale Inc
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

#TODO: this compat package should no longer be necessary, chef service resource does not
# require this and it was only used for legacy templates afaik.
#install rs_utils command for ubuntu
#package "sysvconfig" do
#  only_if { @node[:platform] == "ubuntu" }
#end

#setup timezone
link "/usr/share/zoneinfo/#{@node[:rs_utils][:timezone]}" do 
  to "/etc/localtime"
end

#configure syslog
if "#{@node[:rightscale][:servers][:lumberjack][:hostname]}" != ""
  package "syslog-ng" 

  execute "ensure_dev_null" do 
    creates "/dev/null.syslog-ng"
    command "mknod /dev/null.syslog-ng c 1 3"
  end

  service "syslog-ng" do
    supports :start => true, :stop => true, :restart => true
    action [ :enable ]
  end

  template "/etc/syslog-ng/syslog-ng.conf" do
    source "syslog.erb"
    notifies :restart, resources(:service => "syslog-ng")
  end

  bash "configure_logrotate_for_syslog" do 
    code <<-EOH
      perl -p -i -e 's/weekly/daily/; s/rotate\s+\d+/rotate 7/' /etc/logrotate.conf
      [ -z "$(grep -lir "missingok" #{@node[:rs_utils][:logrotate_config]}_file)" ] && sed -i '/sharedscripts/ a\    missingok' #{@node[:rs_utils][:logrotate_config]}
      [ -z "$(grep -lir "notifempty" #{@node[:rs_utils][:logrotate_config]}_file)" ] && sed -i '/sharedscripts/ a\    notifempty' #{@node[:rs_utils][:logrotate_config]}
    EOH
  end
end

directory "/var/spool/oldmail" do 
  recursive true 
  mode "775"
  owner "root"
  group "mail"
end

remote_file "/etc/logrotate.d/mail" do 
  source "mail"
end

#configure collectd
package "collectd" 

# use collectdmon
if node[:platform] == 'centos'
  remote_file "/etc/init.d/collectd" do
    source "collectd-init-centos-with-monitor"
    mode 0755
  end
end

service "collectd" do 
  action :enable
end

# create collectd types.db file unless it already exists


if node.platform == "ubuntu"
  package "liboping0" 

  if node..platform_version != "8.04"
    remote_file ::File.join(node[:rs_utils][:collectd_lib], 'types.db') do 
      not_if { ::File.exists?(::File.join(node[:rs_utils][:collectd_lib], 'types.db')) }
      source "karmic_types.db"
    end

    execute "ln -s /usr/share/collectd/types.db /usr/lib/collectd/types.db"     
  end  
end

directory @node[:rs_utils][:collectd_plugin_dir] do
  recursive true
end

template @node[:rs_utils][:collectd_config] do 
  source "collectd.config.erb"
  notifies :restart, resources(:service => "collectd")
end

# configure process monitoring
template File.join(@node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

right_link_tag "rs_monitoring:state=active"

# TODO: remove, this is legacy
#configure cron
#cron "collectd_restart" do 
#  day "4"
#  command "service collectd restart"
#end

#install private key
if "#{@node[:rs_utils][:private_ssh_key]}" != ""
  directory "/root/.ssh" do
    recursive true
  end 
  template "/root/.ssh/id_rsa" do
    source "id_rsa.erb"
    mode 0600
  end
end

#set hostname
if "#{@node[:rs_utils][:hostname]}" != "" 
  execute "set_hostname" do
    command "hostname #{@node[:rs_utils][:hostname]}" 
  end
end
