# include the public recipe to install subversion
include_recipe "subversion"
 
scm "repository sync" do
  destination @node[:repo][:destination]
  repository @node[:repo][:repository]
  revision @node[:repo][:revision]
  
  svn_username  @node[:repo][:svn][:username] 
  svn_password  @node[:repo][:svn][:password] 
  svn_agruments @node[:repo][:svn][:arguments]

  provider Chef::Provider::Subversion  
end
