#
# Cookbook Name:: app_passenger
# Attributes:: app_passenger
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set[:app][:provider] = "app_passenger"

set_unless[:app_passenger][:rails_spawn_method]="conservative"
set_unless[:app_passenger][:apache][:maintenance_page]=""
set_unless[:app_passenger][:apache][:php_enable]="false"
set_unless[:app_passenger][:apache][:serve_local_files]="true"
set_unless[:app_passenger][:apache][:port]="8000"

case node[:platform]
  when "ubuntu","debian"
    set[:app_passenger][:apache][:user]="www-data"
    set[:app_passenger][:apache][:install_dir]="/etc/apache2"
    set[:app_passenger][:apache][:log_dir]="/var/log/apache2"
    set[:app_passenger][:packages_install] = ["libopenssl-ruby", "libcurl4-openssl-dev", "apache2-mpm-prefork", "apache2-prefork-dev", "libapr1-dev", "libcurl4-openssl-dev"]
    #set[:app_passenger][:ruby_packages_install] = []
      set[:app_passenger][:apache][:demon]="apache2"

  when "centos","redhat","redhatenterpriseserver","fedora","suse"
    set[:app_passenger][:apache][:user]="apache"
    set[:app_passenger][:apache][:install_dir]="/etc/httpd"
    set[:app_passenger][:apache][:log_dir]="/var/log/httpd"

    set[:app_passenger][:packages_install] = ["zlib-devel", "openssl-devel", "readline-devel", "curl-devel", "openssl-devel", "httpd-devel", "apr-devel", "apr-util-devel", "readline-devel"]
    #set[:app_passenger][:ruby_packages_install] = ["]
        set[:app_passenger][:apache][:demon]="httpd"

  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

set[:app_passenger][:deploy_dir]="/home/rails/#{node[:web_apache][:application_name]}"
#set[:app_passenger][:public_root]="#{node[:app_passenger][:deploy_dir]}/current/public"
set[:app_passenger][:public_root]="#{node[:app_passenger][:deploy_dir]}/public"

set[:app_passenger][:ruby_gem_base_dir]="/opt/ruby-enterprise/lib/ruby/gems/1.8"
set[:app_passenger][:gem_bin]="/opt/ruby-enterprise/bin/gem"
set[:app_passenger][:ruby_bin]="/opt/ruby-enterprise/bin/ruby"
set[:app_passenger][:apache_psr_install_module]="/opt/ruby-enterprise/bin/passenger-install-apache2-module"

#set_unless[:app_passenger][:repository][:type]="git"
#set_unless[:app_passenger][:repository][:revision]="HEAD"
#set_unless[:app_passenger][:repository][:url]=""
#set_unless[:app_passenger][:repository][:svn][:password]=""
#set_unless[:app_passenger][:repository][:svn][:username]=""
#set_unless[:app_passenger][:repository][:git][:credentials]=""

set_unless[:app_passenger][:project][:environment]="development"
set_unless[:app_passenger][:project][:gem_list]=""
set_unless[:app_passenger][:project][:custom_cmd]=""

#set_unless[:app_passenger][:project][:migration_cmd]=""
#set_unless[:app_passenger][:project][:migrate]=false
#if node[:app_passenger][:project][:migration_cmd]!=""
#  set_unless[:app_passenger][:project][:migrate]=true
#end

set_unless[:app_passenger][:project][:db][:schema_name]=""
set_unless[:app_passenger][:project][:db][:adapter]="mysql"

