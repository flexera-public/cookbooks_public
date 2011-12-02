#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# include the public recipe for basic installation
include_recipe "apache2"

# Persist apache2 resource to node for use in other run lists
service "apache2" do
  action :nothing
  persist true  
end

if node[:web_apache][:ssl_enable]
  include_recipe "apache2::mod_ssl"
end

## Move Apache
content_dir = '/mnt/www'
ruby 'move_apache' do
  not_if do File.directory?(content_dir) end
  code <<-EOH
    `mkdir -p #{content_dir}`
    `cp -rf /var/www/. #{content_dir}`
    `rm -rf /var/www`
    `ln -nsf #{content_dir} /var/www`
  EOH
end

## Move Apache Logs
apache_name = node[:apache][:dir].split("/").last
log "apache_name was #{apache_name}"
log "apache log dir was #{node[:apache][:log_dir]}"
ruby 'move_apache_logs' do
  not_if do File.symlink?(node[:apache][:log_dir]) end
  code <<-EOH
    `rm -rf #{node[:apache][:log_dir]}`
    `mkdir -p /mnt/log/#{apache_name}`
    `ln -s /mnt/log/#{apache_name} #{node[:apache][:log_dir]}`
  EOH
end

# Configuring Apache Multi-Processing Module
case node[:platform]
  when "centos","redhat","fedora","suse"

    binary_to_use = node[:apache][:binary]
    if node[:web_apache][:mpm] != 'prefork'
      binary_to_use << ".worker"
    end

    template "/etc/sysconfig/httpd" do
      source "sysconfig_httpd.erb"
      mode "0644"
      variables(
        :sysconfig_httpd => binary_to_use
      )
      notifies :reload, resources(:service => "apache2"), :immediately
    end
  when "debian","ubuntu"
    package "apache2-mpm-#{node[:web_apache][:mpm]}"
end

# Log resource submitted to opscode. http://tickets.opscode.com/browse/CHEF-923
log "Started the apache server."

rs_utils_marker :end
