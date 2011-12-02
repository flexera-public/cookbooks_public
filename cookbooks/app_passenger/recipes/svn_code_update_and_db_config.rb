# Cookbook Name:: app_passenger
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


rs_utils_marker :begin


# Preparing dirs, required for apache+passenger
  log "INFO: Creating directory for project deployment - #{node[:app_passenger][:deploy_dir]}"
directory node[:app_passenger][:deploy_dir] do
  recursive true
end

  log "INFO: Creating log directory - #{node[:app_passenger][:log_dir]}"
directory node[:app_passenger][:log_dir] do
  recursive true
end

#Deleting tmp pull directory for repo_git_pull correct operations
directory "#{node[:app_passenger][:deploy_dir].chomp}/tmp/" do
  recursive true
  action :delete
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
case node[:app_passenger][:opt_svn_type]
  when "svn"
#cloning from SVN

    directory "/root/.subversion/" do
      recursive true
    end
#Creating subversion config for run without promts
  log "Creating subversion config"
    template "/root/.subversion/servers" do
      source "svn_servers.erb"
    end

#deploy!
    deploy node[:app_passenger][:deploy_dir] do
      scm_provider Chef::Provider::Subversion
      repo "#{node[:app_passenger][:opt_svn_repository].chomp}"
      svn_username node[:app_passenger][:opt_svn_username]
      svn_password node[:app_passenger][:opt_svn_password]
      revision node[:app_passenger][:opt_svn_revision]
      user node[:app_passenger][:apache_user]
      enable_submodules true
      migrate node[:app_passenger][:migrate]
      migration_command "/opt/ruby-enterprise/bin/#{node[:app_passenger][:migration_cmd]}"
      environment "RAILS_ENV" => "#{node[:app_passenger][:environment]}"
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt"
      create_dirs_before_symlink
    end

  when "git"
#cloning from git
    repo_git_pull "Get Repository" do
      url "#{node[:app_passenger][:opt_svn_repository].chomp}"
      branch node[:app_passenger][:opt_svn_revision]
      dest "#{node[:app_passenger][:deploy_dir].chomp}/tmp/"
      cred  node[:app_passenger][:opt_svn_credentials]
    end

#deploy!
    deploy node[:app_passenger][:deploy_dir] do
      repo "#{node[:app_passenger][:deploy_dir].chomp}/tmp"
      user node[:app_passenger][:apache_user]
      enable_submodules true
      migrate node[:app_passenger][:migrate]
      migration_command "/opt/ruby-enterprise/bin/#{node[:app_passenger][:migration_cmd]}"
      environment "RAILS_ENV" => "#{node[:app_passenger][:environment]}"
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt"
      create_dirs_before_symlink
    end

end
#creating database template
  log "Generating database.yml"
template "#{node[:app_passenger][:deploy_dir].chomp}/current/config/database.yml" do
  owner node[:app_passenger][:apache_user]
  source "database.yml.erb"
  action :create_if_missing
end

#setting $RAILS_ENV
ENV['RAILS_ENV'] = node[:app_passenger][:environment]

#Creating bash file for manual $RAILS_ENV setup
  log "Creating bash file for manual $RAILS_ENV setup"
template "/etc/profile.d/rails_env.sh" do
  mode '0744'
  source "rails_env.erb"
end


rs_utils_marker :end