# Cookbook Name:: app_tomcat
# Recipe:: do_update_code
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

# Check that we have the required attributes set
raise "You must provide a URL to your application code repository" if ("#{node[:tomcat][:code][:url]}" == "")
raise "You must provide a destination for your application code." if ("#{node[:tomcat][:docroot]}" == "")

# Warn about missing optional attributes
Log("WARNING: You did not provide credentials for your code repository -- assuming public repository.") if ("#{node[:tomcat][:code][:credentials]}" == "")
Log("You did not provide branch informaiton -- setting to default.") if ("#{node[:tomcat][:code][:branch]}" == "")

#########################################################
node[:tomcat][:docroot] = "/srv/tomcat6/webapps/"

log "INFO: Creating directory for project deployment - #{node[:app_passenger][:deploy_dir]}"
directory node[:app_passenger][:deploy_dir] do
  recursive true
end

#Deleting tmp pull directory for repo_git_pull correct operations
directory "#{node[:app_passenger][:deploy_dir].chomp}/tmp/" do
  recursive true
  action :delete
end

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

    subversion "Get Repository SVN" do
      repository node[:tomcat][:code][:url]
      revision node[:tomcat][:code][:branch]
      svn_username node[:tomcat][:code][:svn_username]
      svn_password node[:tomcat][:code][:svn_password]
      destination "#{node[:tomcat][:docroot].chomp}/tmp"
      action :sync
    end

#deploy!
    deploy node[:app_passenger][:deploy_dir] do
      scm_provider Chef::Provider::Subversion
      repo node "#{node[:tomcat][:docroot].chomp}/tmp" #"#{[:tomcat][:code][:url].chomp}" #"#{node[:app_passenger][:repository][:url].chomp}"
      #svn_username node[:tomcat][:code][:svn_username] #node[:app_passenger][:repository][:svn][:username]
      #svn_password node[:tomcat][:code][:svn_password] #node[:app_passenger][:repository][:svn][:password]
      #revision node[:tomcat][:code][:branch] #node[:app_passenger][:repository][:revision]
      user node[:tomcat][:app_user] #node[:app_passenger][:apache][:user]
      enable_submodules true
      migrate false
#      migration_command "/opt/ruby-enterprise/bin/#{node[:app_passenger][:project][:migration_cmd]}"
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt" #"/etc/init.d/tomcat6 restart"
      create_dirs_before_symlink
    end

  when "git"
=begin
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
=end
end

##########################################################
=begin

# Execute once, on first boot
#if (! node[:delete_docroot_executed])
#  log("Deleting the original docroot")
#  directory "#{node[:tomcat][:docroot]}" do
#    recursive true
#    action :delete
#  end

  log("Cloning repository to #{node[:tomcat][:docroot]}")
  # Clone to grab application source from remote repository. Pull is done in the next bash script

  case node[:tomcat][:code][:repo_type]

    #cloning from SVN
    when "svn"
      #Creating SVN config
      directory "/root/.subversion/" do
        recursive true
      end

      #Creating Tomcat DocRoot
      directory "#{node[:tomcat][:docroot]}" do
        recursive true
        owner node[:tomcat][:app_user]
        not_if do (File.exists?("#{node[:tomcat][:docroot]}")) end
      end


  #Create subversion config for run without promts
  log "Creating subversion config"

      template "/root/.subversion/servers" do
        source "svn_servers.erb"
      end

      subversion "Get Repository SVN" do
        repository node[:tomcat][:code][:url]
        revision node[:tomcat][:code][:branch]
        svn_username node[:tomcat][:code][:svn_username]
        svn_password node[:tomcat][:code][:svn_password]
        destination node[:tomcat][:docroot]
        action :sync
      end

    #cloning from GIT
    when "git"

      repo_git_pull "Get Repository git" do
        url    node[:tomcat][:code][:url]
        branch node[:tomcat][:code][:branch]
        dest   node[:tomcat][:docroot]
        cred   node[:tomcat][:code][:credentials]
      end

      bash "Update git Repository" do
        flags "-ex"
        code <<-EOH
          cd #{node[:tomcat][:docroot]}
          git_pull_output=$(git pull)
          if grep -i -q "Already up-to-date"<<<$git_pull_output && test "#{node[:delete_docroot_executed]}" = "true"; then
            echo "Code is up-to-date, exiting successfully"
            exit 0
          fi
        EOH
      end

  end
#end  #if node[:delete_docroot_executed]

#    git_pull_output=$(git pull)
#    if grep -i -q "Already up-to-date"<<<$git_pull_output && test "#{node[:delete_docroot_executed]}" = "true"; then
#      echo "Code is up-to-date, exiting successfully"
#      exit 0
#    fi
=end

node[:tomcat][:docroot] = "/srv/tomcat6/webapps/current"

# Set ROOT war and code ownership
bash "set_root_war_and_chown_home" do
  flags "-ex"
  code <<-EOH
    cd #{node[:tomcat][:docroot]}
    if [ ! -z "#{node[:tomcat][:code][:root_war]}" -a -e "#{node[:tomcat][:docroot]}/#{node[:tomcat][:code][:root_war]}" ] ; then
      mv #{node[:tomcat][:docroot]}/#{node[:tomcat][:code][:root_war]} #{node[:tomcat][:docroot]}/ROOT.war
    fi
    chown -R #{node[:tomcat][:app_user]}:#{node[:tomcat][:app_user]} #{node[:tomcat][:docroot]}
  EOH
end

node[:delete_docroot_executed] = true

rs_utils_marker :end
