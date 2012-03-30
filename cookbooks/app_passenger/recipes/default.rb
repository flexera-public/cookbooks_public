#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Setting provider specific settings for rails-passenger."
node[:app][:provider] = "app_passenger"
node[:app][:destination]="/home/rails/#{node[:web_apache][:application_name]}"
node[:app][:database_name] = node[:app_passenger][:project][:db][:schema_name]
node[:app][:root] = "#{node[:app][:destination]}/public"
node[:app][:port] = 8000


case node[:platform]
  when "ubuntu","debian"
    node[:app][:packages] = ["libopenssl-ruby", "libcurl4-openssl-dev", "apache2-mpm-prefork", "apache2-prefork-dev", "libapr1-dev", "libcurl4-openssl-dev"]
  when "centos","redhat","redhatenterpriseserver","fedora","suse"
    node[:app][:packages] = ["zlib-devel", "openssl-devel", "readline-devel", "curl-devel", "openssl-devel", "httpd-devel", "apr-devel", "apr-util-devel", "readline-devel"]
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

rs_utils_marker :end
