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
node[:tomcat][:docroot] = "/srv/tomcat6/webapps"

log "INFO: Creating directory for project deployment - #{node[:tomcat][:docroot]}"
directory node[:tomcat][:docroot] do
  recursive true
end

#Create deploy system dirs
directory "#{node[:tomcat][:docroot].chomp}/shared/" do
  recursive true
end

#directory "#{node[:tomcat][:docroot].chomp}/shared/system" do
#  recursive true
#end


case node[:tomcat][:code][:repo_type]
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
    deploy node[:tomcat][:docroot] do
      scm_provider Chef::Provider::Subversion
      repo  "#{node[:tomcat][:code][:url].chomp}" #"#{node[:tomcat][:docroot].chomp}/tmp" #"#{node[:app_passenger][:repository][:url].chomp}"
      svn_username node[:tomcat][:code][:svn_username] #node[:app_passenger][:repository][:svn][:username]
      svn_password node[:tomcat][:code][:svn_password] #node[:app_passenger][:repository][:svn][:password]
      revision node[:tomcat][:code][:branch] #node[:app_passenger][:repository][:revision]
      user node[:tomcat][:app_user] #node[:app_passenger][:apache][:user]
      enable_submodules true
      migrate false
      symlink_before_migrate({})
      symlinks({})
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt" #"/etc/init.d/tomcat6 restart"
    end

  when "git"

    log "INFO: Deleting #{node[:tomcat][:docroot].chomp}/tmp  pull directory for repo_git_pull correct operations"
    directory "#{node[:tomcat][:docroot].chomp}/tmp/" do
      recursive true
      action :delete
    end

    log "INFO: Pullng from #{node[:tomcat][:code][:url]} branch #{node[:tomcat][:code][:branch]}"
    repo_git_pull "Get Repository git" do
      url "#{node[:tomcat][:code][:url].chomp}"
      branch node[:tomcat][:code][:branch]
      dest "#{node[:tomcat][:docroot].chomp}/tmp"
      cred node[:tomcat][:code][:credentials]
    end

#deploy!
    deploy node[:tomcat][:docroot] do
      repo  "#{node[:tomcat][:docroot].chomp}/tmp" #"#{node[:app_passenger][:repository][:url].chomp}"
      revision node[:tomcat][:code][:branch] #node[:app_passenger][:repository][:revision]
      user node[:tomcat][:app_user] #node[:app_passenger][:apache][:user]
      enable_submodules true
      migrate false
      symlink_before_migrate({})
      symlinks({})
      shallow_clone true
      action :deploy
      restart_command "touch tmp/restart.txt" #"/etc/init.d/tomcat6 restart"
    end

end

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
