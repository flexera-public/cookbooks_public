#
# Cookbook Name:: app_tomcat
# Recipe:: setup_tomcat_application_vhost
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

template "/etc/tomcat6/tomcat6.conf" do
  action :create
  source "tomcat6_conf.erb"
  group "root"
  owner "root"
  mode "0644"
end

template "/etc/tomcat6/server.xml" do
  action :create
  source "server_xml.erb"
  group "root"
  owner "root"
  mode "0644"
end

template "/etc/logrotate.d/tomcat6" do
  source "tomcat6_logrotate.conf.erb"
  variables :tomcat_name => "tomcat6"
end

service "tomcat6" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

rs_utils_marker :end
