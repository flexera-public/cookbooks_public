#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


#Reading app name from tmp file (for execution in "operational" phase))
if(node[:app_passenger][:deploy_dir]=="/home/rails/")
  app_name = IO.read('/tmp/appname')
  node[:app_passenger][:deploy_dir]="/home/rails/#{app_name.to_s.chomp}"
end



# Preparing dirs, required for apache+passenger
log "INFO: Creating directory for project deployment - <#{node[:app_passenger][:deploy_dir]}>"
directory node[:app_passenger][:deploy_dir] do
  recursive true
end



log "Backup old project dirs "
#backuping old dirs
ruby_block "rename_old_dirs" do
  block do
    shared_dir="#{node[:app_passenger][:deploy_dir]}shared"
    t=Time.now.gmtime
    now=t.strftime("%Y%m%d%H%M%S")

    if File.exists?("#{shared_dir}/log")
      File.rename("#{shared_dir}/log", "#{shared_dir}/log.#{now}")
    end

    if File.exists?("#{shared_dir}/system")
      File.rename("#{shared_dir}/system", "#{shared_dir}/system.#{now}")
    end

  end
end


directory "#{node[:app_passenger][:deploy_dir].chomp}/shared/log" do
  recursive true
end

directory "#{node[:app_passenger][:deploy_dir].chomp}/shared/system" do
  recursive true
end


# pulling project repo
#We use case conditional here because our definitions doesn't support builtin chef conditionals for now
#hope we implement it someday
case node[:app_passenger][:repository][:type]
  when "svn"
#cloning from SVN

    directory "/root/.subversion/" do
      recursive true
    end
#Creating subversion config for run without promts
log "INFO: Creating subversion config"
    template "/root/.subversion/servers" do
      source "svn_servers.erb"
    end

#deploy!
    deploy node[:app_passenger][:deploy_dir] do
      scm_provider Chef::Provider::Subversion
      repo "#{node[:app_passenger][:repository][:url].chomp}"
      svn_username node[:app_passenger][:repository][:svn][:username]
      svn_password node[:app_passenger][:repository][:svn][:password]
      revision node[:app_passenger][:repository][:revision]
      user node[:app_passenger][:apache][:user]
      enable_submodules true
      migrate node[:app_passenger][:project][:migrate]
      migration_command "/opt/ruby-enterprise/bin/#{node[:app_passenger][:project][:migration_cmd]}"
      environment "RAILS_ENV" => "#{node[:app_passenger][:project][:environment]}"
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt"
      create_dirs_before_symlink
    end

  when "git"
    #Deleting tmp pull directory for repo_git_pull correct operations
    directory "#{node[:app_passenger][:deploy_dir].chomp}/tmp/" do
      recursive true
      action :delete
    end

    #cloning from git
    repo_git_pull "Get Repository" do
      url "#{node[:app_passenger][:repository][:url].chomp}"
      branch node[:app_passenger][:repository][:revision]
      dest "#{node[:app_passenger][:deploy_dir].chomp}/tmp/"
      cred  node[:app_passenger][:repository][:git][:credentials]
    end

#deploy!
    deploy node[:app_passenger][:deploy_dir] do
      repo "#{node[:app_passenger][:deploy_dir].chomp}/tmp"
      user node[:app_passenger][:apache][:user]
      enable_submodules true
      migrate node[:app_passenger][:project][:migrate]
      migration_command "/opt/ruby-enterprise/bin/#{node[:app_passenger][:project][:migration_cmd]}"
      environment "RAILS_ENV" => "#{node[:app_passenger][:project][:environment]}"
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt"
      create_dirs_before_symlink
    end

end


rs_utils_marker :end