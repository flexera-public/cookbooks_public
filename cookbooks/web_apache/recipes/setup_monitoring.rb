service "collectd" do
  action :nothing
end

service "httpd" do
  action :nothing
end

if node[:platform] == 'centos'
  if node[:kernel][:machine] == "x86_64"
    ruby_block "install collectd-apache rpms x86_64" do
      block do
        packages = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", "*64.rpm")
        packages.each do |package|
          Chef::Log.info `rpm -i #{package} --nodeps`
          raise "FATAL: error installing rpm #{package}" unless $?.success?
        end
      end
    end
  else
    ruby_block "install collectd-apache rpms i386" do
      block do
        packages = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", "*i386.rpm")
        packages.each do |package|
          Chef::Log.info `rpm -i #{package} --nodeps`
          raise "FATAL: error installing rpm #{package}" unless $?.success?
        end
      end
    end
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
  end

  # Load the exec plugin in the main config file
  rs_utils_enable_collectd_plugin "exec"

  if node[:web_apache][:mpm] == "prefork"
    node[:rs_utils][:process_list] += " httpd"
  else
    node[:rs_utils][:process_list] += " httpd.worker"
  end
 
  template File.join(node[:rs_utils][:collectd_plugin_dir], 'processes.conf') do
    backup false
    source "processes.conf.erb"
    notifies :restart, resources(:service => "collectd")
  end
else
  Chef::Log.info "WARNING: attempting to install collectd-apache on unsupported platform #{node[:platform]}, continuing.."
end
