#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
cookbook_file "/etc/postfix/main.cf" do
  only_if { node[:platform] =~ /centos|redhat/ }
  source "postfix.main.cf"
  mode "0644"
  backup 5
end

# On CentOS 5.6 and RedHat 5.6, default MTA is sendmail.
# Change default MTA to postfix.
execute "set_postfix_default_mta" do
  only_if { node[:platform] =~ /centos|redhat/ }
  command "alternatives --set mta /usr/sbin/sendmail.postfix"
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

cookbook_file "/etc/logrotate.d/mail" do
  source "mail"
end

rs_utils_marker :end
