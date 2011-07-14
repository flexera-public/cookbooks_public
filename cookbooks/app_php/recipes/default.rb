# Cookbook Name:: app_php
# Recipe:: default
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

# Install the IUS repo
remote_file "/root/ius-release-1.0-8.ius.el5.noarch.rpm" do
  source "ius-release-1.0-8.ius.el5.noarch.rpm"
end

remote_file "/root/epel-release-1-1.ius.el5.noarch.rpm" do
  source "epel-release-1-1.ius.el5.noarch.rpm"
end

bash "rpm install of IUS repository" do
  code <<EOF
  rpm -Uvh /root/epel-release-1-1.ius.el5.noarch.rpm
  rpm -Uvh /root/ius-release-1.0-8.ius.el5.noarch.rpm
  yum install -y yum-plugin-replace
EOF
end

ruby_block("reload-yum-cache") do
  block do
    Chef::Provider::Package::Yum::YumCache.instance.reload
  end
end

# == Install user-specified Packages and Modules
#
[ node[:php][:package_dependencies] | node[:php][:modules_list] ].flatten.each do |p|
  package p
end

node[:php][:module_dependencies].each do |mod|
  apache_module mod
end
