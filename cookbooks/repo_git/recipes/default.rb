#
# Cookbook Name:: repo_git
# Recipe:: default
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

unless node[:platform] == "mac_os_x" then
  # Install git client
  case node[:platform]
  when "debian", "ubuntu"
    package "git-core"
  else 
    package "git"
  end

  package "gitk"
  package "git-svn"
  package "git-email"
end

rs_utils_marker :end
