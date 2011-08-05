# Cookbook Name:: app_tomcat
# Recipe:: do_update_code

# Check that we have the required attributes set

raise "You must provide a URL to your application code repository" if node[:tomcat][:code][:url] == "" 
# TODO
#raise "You must provide a destination for your application code." if node[:tomcat][:docroot] == ""

# Warn about missing optional attributes
Chef::Log.warn("WARNING: You did not provide credentials for your code repository -- assuming public repository.") if ("#{node[:tomcat][:code][:credentials]}" == "") 
Chef::Log.info("You did not provide branch informaiton -- setting to default.") if ("#{node[:tomcat][:code][:branch]}" == "") 

# grab application source from remote repository
repo_git_pull "Get Repository" do
  url node[:tomcat][:code][:url]
  branch node[:tomcat][:code][:branch] 
# TODO
#  dest node[:tomcat][:docroot]

  cred node[:tomcat][:code][:credentials]
end

# == Set code ownership 
#bash "chown_home" do
#  code <<-EOH
#    chown -R #{node[:tomcat][:app_user]}:#{node[:tomcat][:app_user]} #{node[:web_apache][:docroot]}
#  EOH
#end
# TODO
#directory node[:tomcat][:docroot] do
#  owner node[:tomcat][:app_user]
#  group node[:tomcat][:app_user]
#  recursive true
#end
