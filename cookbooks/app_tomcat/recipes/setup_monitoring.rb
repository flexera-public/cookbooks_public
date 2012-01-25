# Cookbook Name:: web_apache
# Recipe:: setup_monitoring
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

# add the collectd exec plugin to the set of collectd plugins if it isn't already there
rs_utils_enable_collectd_plugin 'exec'

if !File.exists?("/usr/share/java/collectd.jar")
  # rebuild the collectd configuration file if necessary
  include_recipe "rs_utils::setup_monitoring"

  if node[:platform] == 'centos'

    cookbook_file "/usr/share/java/collectd.jar" do
      source "collectd.jar"
      mode "0644"
    end

    bash "Configure collectd for tomcat" do
      flags "-ex"
      code <<-EOH
        [ -d /usr/share/tomcat6/lib ] && ln -s /usr/share/java/collectd.jar /usr/share/tomcat6/lib

        cat <<EOF>>/etc/tomcat6/tomcat6.conf
CATALINA_OPTS="\$CATALINA_OPTS -Djcd.host=#{node[:rightscale][:instance_uuid]} -Djcd.instance=tomcat6 -Djcd.dest=udp://#{node[:rightscale][:servers][:sketchy][:hostname]}:3011 -Djcd.tmpl=javalang,tomcat -javaagent:/usr/share/tomcat6/lib/collectd.jar"
EOF
      EOH
    end

  service "tomcat6" do
    action [ :stop ]
  end

  sleep 3

  service "tomcat6" do
    action [ :start ]
  end

  else
    Chef::Log.info "WARNING: attempting to install collectd-tomcat on unsupported platform #{node[:platform]}."
  end
else
  log("Collectd plugin for Tomcat already installed, skipping...")
end
