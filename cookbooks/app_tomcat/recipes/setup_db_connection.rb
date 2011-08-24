# Cookbook Name:: app_tomcat
# Recipe:: setup_db_connection
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

# == Setup tomcat Database Connection
#

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
