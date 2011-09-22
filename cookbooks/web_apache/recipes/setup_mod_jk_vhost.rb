# Cookbook Name:: web_apache
# Recipe:: setup_mod_jk_vhost
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

etc_apache = "/etc/#{node[:apache][:config_subdir]}"

#check if mod_jk is installed
if !File.exists?("#{etc_apache}/conf.d/mod_jk.conf")

arch = node[:kernel][:machine]
connectors_source = "tomcat-connectors-1.2.32-src.tar.gz"

if arch == "x86_64"
  bash "install_remove" do
    code <<-EOH
      yum install apr-devel.x86_64 -y
      yum remove apr-devel.i386 -y
    EOH
  end
end

if node[:platform] == 'centos'
  remote_file "/tmp/#{connectors_source}" do
    source "#{connectors_source}"
  end
  package "httpd-devel" do
    action :install
    options "-y"
  end
end

bash "install_tomcat_connectors" do
  flags "-ex"
  code <<-EOH
    cd /tmp
    mkdir -p /tmp/tc-unpack
    tar xzf #{connectors_source} -C /tmp/tc-unpack --strip-components=1

    cd tc-unpack/native
    ./buildconf.sh
    ./configure --with-apxs=/usr/sbin/apxs --quiet
    make -s
    su -c 'make install'
  EOH
end

# == Configure workers.properties for mod_jk
#
template "/etc/tomcat6/workers.properties" do
  action :create
  source "tomcat_workers.properties.erb"
  variables :tomcat_name => "tomcat6"
end

# == Configure mod_jk conf
#
template "#{etc_apache}/conf.d/mod_jk.conf" do
  action :create
  backup false
  source "mod_jk.conf.erb"
  variables :tomcat_name => "tomcat6"
end

log "Finished configuring mod_jk, creating the application vhost..."

execute "Enable a2enmod apache module" do
  command "a2enmod rewrite && a2enmod deflate"
end

if ("#{node[:tomcat][:code][:root_war]}" == "")
  log "root_war not defined, setting apache docroot to #{node[:tomcat][:docroot]}"
  docroot4apache = "#{node[:tomcat][:docroot]}"
else
  log "root_war defined, setting apache docroot to #{node[:tomcat][:docroot]}/ROOT"
  docroot4apache = "#{node[:tomcat][:docroot]}/ROOT"
end

# == Configure apache vhost for tomcat
#
template "#{etc_apache}/sites-enabled/#{node[:web_apache][:application_name]}.conf" do
  action :create_if_missing
  source "apache_mod_jk_vhost.erb"
  variables(
    :docroot     => docroot4apache,
    :vhost_port  => node[:app][:port],
    :server_name => node[:web_apache][:server_name]
  )
end

service "#{node[:apache][:config_subdir]}" do
  action :restart
end

else
  log "mod_jk already installed, skipping the recipe"
end

rs_utils_marker :end