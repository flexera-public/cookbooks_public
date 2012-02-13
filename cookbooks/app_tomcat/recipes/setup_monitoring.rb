#
# Cookbook Name:: web_apache
# Recipe:: setup_monitoring
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

=begin
# add the collectd exec plugin to the set of collectd plugins if it isn't already there
rs_utils_enable_collectd_plugin 'exec'

if !File.exists?("/usr/share/java/collectd.jar")
  # rebuild the collectd configuration file if necessary
  include_recipe "rs_utils::setup_monitoring"

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

  sleep 5

  service "tomcat6" do
    action [ :start ]
  end

else
  log("Collectd plugin for Tomcat already installed, skipping...")
end
=end