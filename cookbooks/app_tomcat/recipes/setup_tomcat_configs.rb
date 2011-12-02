# Cookbook Name:: app_tomcat
# Recipe:: setup_tomcat_application_vhost
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

template "/etc/tomcat6/tomcat6.conf" do
  action :create
  source "tomcat6_conf.erb"
  group "root"
  owner "root"
  mode "0644"
end

bash "Add optional Java XMS and XMX parameters" do
  flags "-ex"
  code <<-EOH
    tc_conf=/etc/tomcat6/tomcat6.conf

    if [ -z "$(grep "OPTS -Xms" $tc_conf)" ] ; then 
      xms_val="512m"
      xmx_val="512m"
      [ -n "#{node[:tomcat][:java][:xms]}" ] && xms_val="#{node[:tomcat][:java][:xms]}"
      [ -n "#{node[:tomcat][:java][:xmx]}" ] && xmx_val="#{node[:tomcat][:java][:xmx]}"
      cat << EOF >> $tc_conf
# Set the memory allocation size
CATALINA_OPTS="\$CATALINA_OPTS -Xms$xms_val -Xmx$xmx_val"
EOF
    fi
  EOH
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
