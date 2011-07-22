service "collectd" do
  action :nothing
end

service "httpd" do
  action :nothing
end

arch = node[:kernel][:machine]
arch = "i386" if arch == "i686"

if node[:platform] == 'centos'

  TMP_FILE = "/tmp/collectd-apache.rpm"

  remote_file TMP_FILE do
    source "collectd-apache-4.10.0-4.el5.#{arch}.rpm"
  end

  package TMP_FILE do
    source TMP_FILE
  end

  template File.join(node[:apache][:dir], 'conf.d', 'status.conf') do
    backup false
    source "apache_status.conf.erb"
    notifies :restart, resources(:service => "httpd")
  end

  directory ::File.join(node[:rs_utils][:collectd_lib], "plugins") do
    action :create
    recursive true
  end

  remote_file(::File.join(node[:rs_utils][:collectd_lib], "plugins", 'apache_ps')) do
    source "apache_ps"
    mode "0755"
  end

  template File.join(node[:rs_utils][:collectd_plugin_dir], 'apache.conf') do
    backup false
    source "apache_collectd_plugin.conf.erb"
    notifies :restart, resources(:service => "collectd")
  end

  template File.join(node[:rs_utils][:collectd_plugin_dir], 'apache_ps.conf') do
    backup false
    source "apache_collectd_exec.erb"
    notifies :restart, resources(:service => "collectd")
  end

  if node[:web_apache][:mpm] == "prefork"
    node[:rs_utils][:process_list] += " httpd"
  else
    node[:rs_utils][:process_list] += " httpd.worker"
  end
 
  template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
    backup false
    cookbook "rs_utils"
    source "processes.conf.erb"
    notifies :restart, resources(:service => "collectd")
  end
else
  Chef::Log.info "WARNING: attempting to install collectd-apache on unsupported platform #{node[:platform]}, continuing.."
end
