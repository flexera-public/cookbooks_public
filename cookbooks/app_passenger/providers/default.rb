# Cookbook Name:: app_passenger
# Provider:: app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#stop apache/passenger
action :stop do
  bash "Stopping apache" do
    flags "-ex"
    code <<-EOH
     /etc/init.d/#{node[:apache][:config_subdir]} stop
    EOH
  end
end

#start apache/passenger
action :start do
  bash "Starting apache" do
    flags "-ex"
    code <<-EOH
     /etc/init.d/#{node[:apache][:config_subdir]} start
    EOH
  end
end

#restart apache/passenger
action :restart do
  action_stop
  sleep 5
  action_start
end

# Installing required packages to system
action :install do

  #Installing some apache development headers required for rubyEE
  packages = new_resource.packages
  log "Packages which will be installed #{packages}"
  #log "Packages which will be installed #{node[:app_passenger][:packages_install]}"
  #node[:app_passenger][:packages_install].each do |p|
  packages.each do |p|
    package p
  end

  #Saving project name variables
  ENV['RAILS_APP'] = node[:web_apache][:application_name]

  bash "save global vars" do
    code <<-EOH
      echo $RAILS_APP >> /tmp/appname
    EOH
  end

  log "  Installing Ruby Enterprise Edition..."
  cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
    source "ruby-enterprise_x86_64.tar.gz"
    mode "0644"
    only_if do node[:kernel][:machine].include? "x86_64" end
    cookbook 'app_passenger'
  end

  cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
    source "ruby-enterprise_i686.tar.gz"
    mode "0644"
    only_if do node[:kernel][:machine].include? "i686" end
    cookbook 'app_passenger'
  end

  bash "install_ruby_EE" do
    flags "-ex"
    code <<-EOH
      tar xzf /tmp/ruby-enterprise-installed.tar.gz -C /opt/
    EOH
    only_if do ::File.exists?("/tmp/ruby-enterprise-installed.tar.gz")  end
  end


  # Installing passenger module
  log"INFO: Installing passenger"
  bash "Install apache passenger gem" do
    flags "-ex"
    code <<-EOH
      /opt/ruby-enterprise/bin/gem install passenger -q --no-rdoc --no-ri
    EOH
    not_if do (::File.exists?("/opt/ruby-enterprise/bin/passenger-install-apache2-module")) end
  end


  bash "Install_apache_passenger_module" do
    flags "-ex"
    code <<-EOH
      /opt/ruby-enterprise/bin/passenger-install-apache2-module --auto
    EOH
    not_if "test -e #{node[:app_passenger][:ruby_gem_base_dir].chomp}/gems/passenger*/ext/apache2/mod_passenger.so"
  end

end

#setup apache/passenger virtual host
action :setup_vhost do

  #Removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
  file "/etc/httpd/conf.d/ssl.conf" do
    action :delete
    backup false
    only_if do ::File.exists?("/etc/httpd/conf.d/ssl.conf")  end
  end


  # Generation of new apache ports.conf, based on user prefs
  template "#{node[:app_passenger][:apache][:install_dir]}/ports.conf" do
    source "ports.conf.erb"
    cookbook 'app_passenger'
  end

  #unlinking default apache vhost if it exists
  link "#{node[:app_passenger][:apache][:install_dir]}/sites-enabled/000-default" do
    action :delete
    only_if "test -L #{node[:app_passenger][:apache][:install_dir].chomp}/sites-enabled/000-default"
  end


  port = new_resource.app_port
  project_root = new_resource.app_root
  # Generation of new vhost config, based on user prefs
  log"INFO: Generating new apache vhost"
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template "basic_vhost.erb"
    docroot  project_root
    vhost_port  port
    server_name node[:web_apache][:server_name]
    rails_env node[:app_passenger][:project][:environment]
    cookbook 'app_passenger'
  end


end

#setup project db connection
action :setup_db_connection do

  if node[:app_passenger][:project][:db][:adapter]=="mysql"

    #packages required for mysql gem
    node[:app_passenger][:mysql_packages_install]= ["mysql", "mysql-devel","mysqlclient15", "mysqlclient15-devel"]

    case node[:platform]

      when "redhat","redhatenterpriseserver", "centos"
        node[:app_passenger][:mysql_packages_install].each do |p|
          package p
       end

      when "ubuntu","debian"
        log "Nothing to do!"
    end
  end


  deploy_dir = new_resource.destination
  #creating database template
  log "INFO: Generating database.yml"
  template "#{deploy_dir.chomp}/config/database.yml" do
    owner node[:app_passenger][:apache][:user]
    source "database.yml.erb"
    action :create_if_missing
    cookbook 'app_passenger'
  end

  #setting $RAILS_ENV
  ENV['RAILS_ENV'] = node[:app_passenger][:project][:environment]

  #Creating bash file for manual $RAILS_ENV setup
  log "INFO: Creating bash file for manual $RAILS_ENV setup"
  template "/etc/profile.d/rails_env.sh" do
    mode '0744'
    source "rails_env.erb"
    cookbook 'app_passenger'
  end

end


action :code_update do
 deploy_dir = new_resource.destination

  log "INFO: Creating directory for project deployment - <#{deploy_dir}>"
  directory deploy_dir do
    recursive true
  end

  #Reading app name from tmp file (for execution in "operational" phase))
  #Waiting for "run_lists"
  if(deploy_dir == "/home/rails/")
    app_name = IO.read('/tmp/appname')
    deploy_dir = "/home/rails/#{app_name.to_s.chomp}"
  end

  # Preparing dirs, required for apache+passenger
  directory "#{deploy_dir.chomp}/shared/log" do
    recursive true
  end

  directory "#{deploy_dir.chomp}/shared/system" do
    recursive true
  end

  repo "default" do
   destination deploy_dir
   action :capistrano_pull
   app_user node[:app_passenger][:apache][:user]
   environment "RAILS_ENV" => "#{node[:app_passenger][:project][:environment]}"
   create_dirs_before_symlink
   persist false
  end

end







