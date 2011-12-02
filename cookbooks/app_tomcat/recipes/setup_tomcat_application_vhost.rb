#
# Cookbook Name:: app_tomcat
#

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

service "tomcat6" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

rs_utils_marker :end
