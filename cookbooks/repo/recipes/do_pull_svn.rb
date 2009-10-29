# include the public recipe to install subversion
include_recipe "subversion"
 
# scm "repository sync" do
#   destination @node[:repo][:destination]
#   repository @node[:repo][:repository]
#   revision @node[:repo][:revision]
#   
#   svn_username  @node[:repo][:svn][:username] 
#   svn_password  @node[:repo][:svn][:password] 
#   svn_agruments @node[:repo][:svn][:arguments]
# 
#   provider Chef::Provider::Subversion  
# end

#svn update --no-auth-cache --non-interactive  --username cary --password VgD1631rLY368v https://wush.net/svn/rightscale/cookbooks_test/ cookbooks_test/

params = "--no-auth-cache --non-interactive"
params << " --username #{@node[:repo][:svn][:username]} --password #{@node[:repo][:svn][:password]}" if "#{@node[:repo][:svn][:password]}" != ""
params << " --revision #{@node[:repo][:revision]}" if "#{@node[:repo][:revision]}" != ""

# pull repo (if exist)
ruby "pull-exsiting-local-repo" do
  cwd @node[:repo][:destination]
  only_if do File.directory?(@node[:repo][:destination]) end
  code <<-EOH
    puts "Updateing existing repo at #{@node[:repo][:destination]}"
    puts `svn update #{params} #{@node[:repo][:repository]} #{@node[:repo][:destination]}` 
  EOH
end

# clone repo (if not exist)
ruby "create-new-local-repo" do
  not_if do File.directory?(@node[:repo][:destination]) end
  code <<-EOH
    puts "Creating new repo at #{@node[:repo][:destination]}"
    puts `svn checkout #{params} #{@node[:repo][:repository]} #{@node[:repo][:destination]}`
  EOH
end