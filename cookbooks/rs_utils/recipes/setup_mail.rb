# Cookbook Name:: rs_utils
# Recipe:: mail
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

# == Install and setup postfix 
package "postfix"

service "postfix" do
  action :enable
  supports :status => true
end

# == Update main.cf (if needed)
#
# We make the changes needed for centos, but using the default main.cf 
# config everywhere else
#
remote_file "/etc/postfix/main.cf" do
  only_if { node[:platform] =~ /centos|redhat/ }
  backup 5
  source "postfix.main.cf"
#  notifies :restart, resources(:service => "postfix")
end

# On CentOS 5.4 postfix is not started and chef tries to 'stop' it.  This throws an error.
# So we'll just start the service here for CentOS.
if node[:platform] =~  /centos|redhat/
  service "postfix" do
    action :start
  end
else node[:platform] == "ubuntu"
  service "postfix" do
    action :restart
  end
end

# == Add mail to logrotate
#
directory "/var/spool/oldmail" do
  recursive true
  mode "775"
  owner "root"
  group "mail"
end

remote_file "/etc/logrotate.d/mail" do
  source "mail"
end

rs_utils_marker :end
