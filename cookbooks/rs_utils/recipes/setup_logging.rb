# Cookbook Name:: rs_utils
# Recipe:: logging
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

if "#{node.rightscale.servers.lumberjack.hostname}" != ""

  log "Configure syslog logging"

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
      [ -z "$(grep -lir "missingok" #{node.rs_utils.logrotate_config}_file)" ] && sed -i '/sharedscripts/ a\    missingok' #{node.rs_utils.logrotate_config}
      [ -z "$(grep -lir "notifempty" #{node.rs_utils.logrotate_config}_file)" ] && sed -i '/sharedscripts/ a\    notifempty' #{node.rs_utils.logrotate_config}
    EOH
  end
  
  right_link_tag "rs_logging:state=active"
  
end
