#
# Cookbook Name:: repo_git
# Recipe:: default
#
# Copyright (c) 2010 RightScale Inc
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

PROVIDER_NAME = "repo_git"  

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

# Setup all git resources that have attributes in the node.
node[:repo].each do |resource_name, entry| 
  if entry[:provider] == PROVIDER_NAME then
    
    url = entry[:repository]
    raise "ERROR: You did not specify a repository for repo resource named #{resource_name}." unless url
    branch = (entry[:branch]) ? entry[:branch] : "master"
    key = (entry[:ssh_key]) ? entry[:ssh_key] : ""
    submodule = (entry[:enable_submodules] == "true") ? true : false

    # Setup git client
    repo resource_name do
      provider "repo_git"
      repository url
      revision branch
      ssh_key key
      enable_submodules submodule      
      # persist true      # developed by RightScale (to contribute)
    end
  end
end
