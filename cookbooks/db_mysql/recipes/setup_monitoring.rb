service "collectd" do
  action :nothing
end

arch = node[:kernel][:machine]
arch = "i386" if arch == "i686"

if node[:platform] == 'centos'

  TMP_FILE = "/tmp/collectd.rpm"

  remote_file TMP_FILE do
    source "collectd-mysql-4.10.0-4.el5.#{arch}.rpm"
  end

  package TMP_FILE do
    source TMP_FILE
  end

  template File.join(node[:rs_utils][:collectd_plugin_dir], 'mysql.conf') do
    backup false
    source "mysql_collectd_plugin.conf.erb"
    notifies :restart, resources(:service => "collectd")
  end
  
else
  
  log "WARNING: attempting to install collectd-mysql on unsupported platform #{node[:platform]}, continuing.." do
    level :warn
  end
  
end




