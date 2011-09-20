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

case platform
when "ubuntu", "debian"
  apache = "/etc/apache2"
when "centos", "fedora", "suse"
  apache = "/etc/httpd"
end
 
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

execute "Rename mod_jk.conf" do
  command "[ -s #{apache}/conf.d/mod_jk.conf ] && mv -f #{apache}/conf.d/mod_jk.conf #{apache}/conf.d/mod_jk.conf.bak.$(date "+%s")"
end

# == Configure mod_jk conf
#
template "#{apache}/conf.d/mod_jk.conf" do
  template "mod_jk.conf.erb"
  tomcat_name "tomcat6"
end

# == Configure apache vhost for tomcat
#
template "/etc/#{node[:apache][:dir]}/sites-enabled/#{web_apache[:application_name]}.conf" do
  template "apache_mod_jk_vhost.erb"
  docroot node[:web_apache][:docroot]
  vhost_port node[:app][:port]
  server_name node[:php][:server_name]
  notifies :restart, resources(:service => "apache2")
#  notifies :restart, resources(:service => "apache2"), :immediately
end
