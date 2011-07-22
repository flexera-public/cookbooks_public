service "collectd" do
  action :nothing
end

if node[:platform] == 'centos'

  TMP_FILE = "/tmp/collectd.rpm"

  remote_file TMP_FILE do
    source "collectd-mysql-4.10.0-4.el5.#{node[:kernel][:machine]}.rpm"
    only_if { node[:platform] == 'centos' }
  end

  package TMP_FILE do
    source "/tmp/collectd.rpm"
    only_if { node[:platform] == 'centos' }
  end

  template File.join(node[:rs_utils][:collectd_plugin_dir], 'mysql.conf') do
    backup false
    source "mysql_collectd_plugin.conf.erb"
    notifies :restart, resources(:service => "collectd")
    only_if { node[:platform] == 'centos' }
  end
  
else
  
  log "WARNING: attempting to install collectd-mysql on unsupported platform #{node[:platform]}, continuing.." do
    level :warn
  end
  
end




