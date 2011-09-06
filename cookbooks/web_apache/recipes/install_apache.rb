# Cookbook Name:: web_apache
# Recipe:: install_apache
#
# Copyright (c) 2009 RightScale Inc
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

package "apache2" do
  case node[:platform]
  when "centos","redhat","fedora","suse"
    package_name "httpd"
  when "debian","ubuntu"
    package_name "apache2"
  end
  action :install
end

service "apache2" do
  # If restarted/reloaded too quickly apache has a habit of failing
  # This may happen with multiple recipes notifying apache to restart - like
  # during the initial bootstrap.
  case node[:platform]
  when "centos","redhat","fedora","suse"
    service_name "httpd"
    restart_command "/sbin/service httpd restart && sleep 1"
    reload_command "/sbin/service httpd reload && sleep 1"
  when "debian","ubuntu"
    service_name "apache2"
    restart_command "service apache2 restart && sleep 1"
    reload_command "service apache2 reload && sleep 1"
  end
  action :nothing
end

# include the public recipe for basic installation
include_recipe "apache2"

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

