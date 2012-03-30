#
# Cookbook Name:: app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:app_passenger][:rails_spawn_method]="conservative"
set_unless[:app_passenger][:apache][:maintenance_page]=""
set_unless[:app_passenger][:apache][:serve_local_files]="true"

set[:app_passenger][:module_dependencies] = ["proxy", "proxy_ajp"]

case node[:platform]
  when "ubuntu","debian"
    set[:app_passenger][:apache][:user]="www-data"
    set[:app_passenger][:apache][:log_dir]="/var/log/apache2"

  when "centos","redhat","redhatenterpriseserver","fedora","suse"
    set[:app_passenger][:apache][:user]="apache"
       set[:app_passenger][:apache][:log_dir]="/var/log/httpd"

  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

set[:app_passenger][:deploy_dir]="/home/rails/#{node[:web_apache][:application_name]}"

set[:app_passenger][:ruby_gem_base_dir]="/opt/ruby-enterprise/lib/ruby/gems/1.8"
set[:app_passenger][:gem_bin]="/opt/ruby-enterprise/bin/gem"
set[:app_passenger][:ruby_bin]="/opt/ruby-enterprise/bin/ruby"
set[:app_passenger][:apache_psr_install_module]="/opt/ruby-enterprise/bin/passenger-install-apache2-module"

set_unless[:app_passenger][:project][:environment]="development"
set_unless[:app_passenger][:project][:gem_list]=""
set_unless[:app_passenger][:project][:custom_cmd]=""

set_unless[:app_passenger][:project][:db][:schema_name]=""
set_unless[:app_passenger][:project][:db][:adapter]="mysql"
