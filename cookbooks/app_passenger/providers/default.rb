# Cookbook Name:: repo
# Provider:: repo_git
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :install do

  #Installing some apache development headers required for rubyEE
  new_resource.packages.each do |p|
    package p
  end

  #Saving project name variables
  ENV['RAILS_APP'] = node[:web_apache][:application_name]

  bash "save global vars" do
    code <<-EOH
      echo $RAILS_APP >> /tmp/appname
    EOH
  end

end

action :setup_vhost do

service "apache2" do
  action :nothing
end

#Removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  backup false
  only_if do File.exists?("/etc/httpd/conf.d/ssl.conf")  end
end


# Generation of new apache ports.conf, based on user prefs
template "#{node[:app_passenger][:apache][:install_dir]}/ports.conf" do
  source "ports.conf.erb"
end

#unlinking default apache vhost if it exists
link "#{node[:app_passenger][:apache][:install_dir]}/sites-enabled/000-default" do
  action :delete
  only_if "test -L #{node[:app_passenger][:apache][:install_dir].chomp}/sites-enabled/000-default"
end


# Generation of new vhost config, based on user prefs
log"INFO: Generating new apache vhost"
web_app "http-#{node[:app_passenger][:apache][:port]}-#{node[:web_apache][:server_name]}.vhost" do
  template "basic_vhost.erb"
  docroot node[:app_passenger][:public_root]
  vhost_port node[:app_passenger][:apache][:port]
  server_name node[:web_apache][:server_name]
  rails_env node[:app_passenger][:project][:environment]
  notifies :restart, resources(:service => "apache2"), :immediately
end


end


#######################################################################

action :pull do

  ruby_block "Before pull" do
    block do
      #check previous repo in case of action change
      if (::File.exists?("#{new_resource.destination}") == true && ::File.symlink?("#{new_resource.destination}") == true && ::File.exists?("/tmp/capistrano_repo") == true)
        ::File.rename("#{new_resource.destination}", "/tmp/capistrano_repo/releases/capistrano_old_"+::Time.now.strftime("%Y%m%d%H%M"))
      end
      # add ssh key and exec script
      RightScale::Repo::Ssh_key.new.create(new_resource.ssh_key)
    end
  end

  # pull repo (if exist)
  ruby_block "Pull existing git repository at #{new_resource.destination}" do
    only_if do ::File.directory?(new_resource.destination) end
    block do
      branch = new_resource.revision

      Dir.chdir new_resource.destination
      puts "Updating existing repo at #{new_resource.destination}"
      #puts `git pull origin #{branch}`
      puts `git pull`
    end
  end

  # clone repo (if not exist)
  ruby_block "Clone new git repository at #{new_resource.destination}" do
    not_if do ::File.directory?(new_resource.destination) end
    block do
      puts "Creating new repo at #{new_resource.destination}"
      puts `git clone #{new_resource.repository} -- #{new_resource.destination}`
      branch = new_resource.revision
      if "#{branch}" != "master"
        dir = "#{new_resource.destination}"
        Dir.chdir(dir) 
        puts `git checkout --track -b #{branch} origin/#{branch}`
      end
    end
  end

  # delete SSH key & clear GIT_SSH
  ruby_block "After pull" do
    block do
      RightScale::Repo::Ssh_key.new.delete
    end
  end
 
end

action :capistrano_pull do

  ruby_block "Before deploy" do
    block do
       RightScale::Repo::Ssh_key.new.create(new_resource.ssh_key)
    end
  end

  destination = new_resource.destination
  repository = new_resource.repository
  revision = new_resource.revision
  app_user = new_resource.app_user
  purge_before_symlink = new_resource.purge_before_symlink
  create_dirs_before_symlink = new_resource.create_dirs_before_symlink
  symlinks = new_resource.symlinks
  scm_provider = new_resource.provider
  environment = new_resource.environment

  capistranize_repo "Source repo" do
    repository                 repository
    revision                   revision
    destination                destination
    app_user                   app_user
    purge_before_symlink       purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks                   symlinks
    scm_provider               scm_provider
    environment                environment
  end

  ruby_block "Before deploy" do
    block do
      RightScale::Repo::Ssh_key.new.delete
    end
  end

end

