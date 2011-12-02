#
# Cookbook Name:: app_rails
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Check that we have the required attributes set
raise "You must provide a URL to your application code repository" if ("#{node[:rails][:code][:url]}" == "") 
raise "You must provide a destination for your application code." if ("#{node[:rails][:code][:destination]}" == "") 

# Warn about missing optional attributes
Chef::Log.warn("WARNING: You did not provide credentials for your code repository -- assuming public repository.") if ("#{node[:rails][:code][:credentials]}" == "") 
Chef::Log.info("You did not provide branch informaiton -- setting to default.") if ("#{node[:rails][:code][:branch]}" == "") 

# grab application source from remote repository
repo_git_pull "Get Repository" do
  url node[:rails][:code][:url]
  branch node[:rails][:code][:branch] 
  dest node[:rails][:code][:destination]
  cred node[:rails][:code][:credentials]
end

rs_utils_marker :end
