#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin
=begin
# Check that we have the required attributes set
raise "You must provide a URL to your application code repository" if ("#{node[:php][:code][:url]}" == "")
raise "You must provide a destination for your application code." if ("#{node[:web_apache][:docroot]}" == "")

# Warn about missing optional attributes
Chef::Log.warn("WARNING: You did not provide credentials for your code repository -- assuming public repository.") if ("#{node[:php][:code][:credentials]}" == "")
Chef::Log.info("You did not provide branch informaiton -- setting to default.") if ("#{node[:php][:code][:branch]}" == "")

# grab application source from remote repository
repo_git_pull "Get Repository" do
  url node[:php][:code][:url]
  branch node[:php][:code][:branch]
  dest node[:web_apache][:docroot]
  cred node[:php][:code][:credentials]
end

# == Set code ownership
bash "chown_home" do
  flags "-ex"
  code <<-EOH
    chown -R #{node[:php][:app_user]}:#{node[:php][:app_user]} #{node[:web_apache][:docroot]}
  EOH
end
=end
rs_utils_marker :end
