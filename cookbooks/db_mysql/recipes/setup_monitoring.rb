service "collectd" do
  action :nothing
end

if node[:platform] == 'centos'
  if node[:kernel][:machine] == "x86_64"
    ruby_block "install collectd-mysql rpms x86_64" do
      block do
        packages = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", "*64.rpm")
        packages.each do |package|
          Chef::Log.info `rpm -i #{package} --nodeps`
          raise "FATAL: error installing rpm #{package}" unless $?.success?
        end
      end
    end
  else
    ruby_block "install collectd-mysql rpms i386" do
      block do
        packages = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", "*i386.rpm")
        packages.each do |package|
          Chef::Log.info `rpm -i #{package} --nodeps`
          raise "FATAL: error installing rpm #{package}" unless $?.success?
        end
      end
    end
  end

  template File.join(node[:rs_utils][:collectd_plugin_dir], 'mysql.conf') do
    backup false
    source "mysql_collectd_plugin.conf.erb"
    notifies :restart, resources(:service => "collectd")
  end

else
  Chef::Log.info "WARNING: attempting to install collectd-mysql on unsupported platform #{node[:platform]}, continuing.."
end


