#
# Cookbook Name:: app_tomcat
#

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

template "/usr/share/tomcat6/webapps/ROOT/dbread.jsp" do
  source "dbread_jsp.erb"
  owner "root"
  group "root"
  mode "0644"
end

# chef 0.8.* uses remote_file, 0.9.* uses cookbook_file
#cookbook_file "/usr/share/tomcat6/lib/jstl-api-1.2.jar" do
remote_file "/usr/share/tomcat6/lib/jstl-api-1.2.jar" do
  source "jstl-api-1.2.jar"
  owner "root"
  group "root"
  mode "0644"
end

# chef 0.8.* uses remote_file, 0.9.* uses cookbook_file
#cookbook_file "/usr/share/tomcat6/lib/jstl-impl-1.2.jar" do
remote_file "/usr/share/tomcat6/lib/jstl-impl-1.2.jar" do
  source "jstl-impl-1.2.jar"
  owner "root"
  group "root"
  mode "0644"
end

rs_utils_marker :end
