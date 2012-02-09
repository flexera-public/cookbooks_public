#
# Cookbook Name:: app_tomcat
# Recipe:: setup_db_connection
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.
# == Setup tomcat Database Connection
#

rs_utils_marker :begin

template "/etc/tomcat6/context.xml" do
  source "context_xml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :user      => node[:db][:application][:user],
    :password  => node[:db][:application][:password],
    :fqdn      => node[:db][:fqdn],
    :database  => node[:tomcat][:db_name]
  )
end

template "/etc/tomcat6/web.xml" do
  source "web_xml.erb"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/usr/share/tomcat6/lib/jstl-api-1.2.jar" do
  source "jstl-api-1.2.jar"
  owner "root"
  group "root"
  mode "0644"
end


cookbook_file "/usr/share/tomcat6/lib/jstl-impl-1.2.jar" do
  source "jstl-impl-1.2.jar"
  owner "root"
  group "root"
  mode "0644"
end

rs_utils_marker :end
