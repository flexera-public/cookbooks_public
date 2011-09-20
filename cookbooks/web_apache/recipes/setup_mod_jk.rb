# Cookbook Name:: web_apache
# Recipe:: setup_mod_jk
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

apache = "/etc/#{node[:apache][:config_subdir]}"  
  
arch = node[:kernel][:machine]

if arch == "x86_64"

  
  package "apr-devel.x86_64" do
    action :install
    options "-y"
  end
  
    package "apr-devel.i386" do
    action :remove
    options "-y"
  end
end

if node[:platform] == 'centos'
  remote_file "/tmp/tomcat-connectors-1.2.26-src.tar.gz" do
    source "tomcat-connectors-1.2.26-src.tar.gz"
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
    tar xzf tomcat-connectors-1.2.26-src.tar.gz -C /tmp/tc-unpack --strip-components=1

    cd tc-unpack/native
    ./buildconf.sh
    ./configure --with-apxs=/usr/sbin/apxs --quiet
    make -s
    su -c 'make install'
  EOH
end

