# Cookbook Name:: db_mysql
# Recipe:: setup_apache_vhost
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


service "apache2" do
  action :nothing
end

# disable default vhost
apache_site "000-default" do
  enable false
end

apache_module "ssl"
# TODO:
# headers and rewrite possible module load

ssl_dir =  "/etc/#{@node[:web_apache][:config_subdir]}/rightscale.d/key"

directory ssl_dir do
  mode "0700"
  recursive true
end

ssl_certificate_file = ::File.join(ssl_dir, "#{node[:php][:server_name]}.crt"
ssl_key_file = ::File.join(ssl_dir, "#{node[:php][:server_name]}.key"

template ssl_certificate_file do
  mode "0400"
  source "ssl_certificate.erb"
end

template ssl_key_file do
  mode "0400"
  source "ssl_key.erb"
end

if node[:web_apache][:ssl_passphrase]
  bash "decrypt openssl keyfile" do
    environment { :OPT_SSL_PASSPHRASE => node[:web_apache][:ssl_passphrase] }
    command "openssl rsa -passin env:OPT_SSL_PASSPHRASE -in #{ssl_key_file} -passout env:OPT_SSL_PASSPHRASE -out #{ssl_key_file}"
  end
end

# Optional certificate chain
if node[:web_apache][:ssl_certificate_chain]
  ssl_certificate_chain_file = ::File.join(ssl_dir, "#{node[:web_apache][:server_name]}.sf_crt"
  template ssl_certificate_chain_file do
    mode "0400"
    source "ssl_certificate_chain.erb"
  end
else
  ssl_certificate_chain_file = nil
end

# == Configure apache vhost for PHP
#
web_app node[:web_apache][:application_name] do
  template "apache_ssl_vhost.erb"
  docroot node[:web_apache][:docroot]
  vhost_port "443"
  server_name node[:web_apache][:server_name]
  ssl_certificate_chain_file ssl_certificate_chain_file
  ssl_passphrase node[:web_apache][:ssl_passphrase]
  ssl_certificate_file ssl_certificate_file
  ssl_key_file ssl_key_file
  notifies :restart, resources(:service => "apache2")
end
