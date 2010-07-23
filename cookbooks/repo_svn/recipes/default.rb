#
# Cookbook Name:: repo_svn
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

PROVIDER_NAME = "repo_svn"  # grab this from cookbook directory name

unless node[:platform] == "mac_os_x" then
  # install subversion client
  package "subversion" do
    action :install
  end

  extra_packages = case node[:platform]
    when "ubuntu","debian"
      if node[:platform_version].to_f < 8.04
        %w{subversion-tools libsvn-core-perl}
      else
        %w{subversion-tools libsvn-perl}
      end
    when "centos","redhat","fedora"
      %w{subversion-devel subversion-perl}
    end

  extra_packages.each do |pkg|
    package pkg do
      action :install
    end
  end
end

# Setup all Subversion resources that have attributes in the node.
node[:repo].each do |resource_name, entry| 
  if entry[:provider] == PROVIDER_NAME then
  
    url = entry[:repository]
    raise "ERROR: You did not specify a repository for repo resource named #{resource_name}." unless url
    branch = (entry[:branch]) ? entry[:branch] : "HEAD"
    username = (entry[:username]) ? entry[:username] : ""
    password = (entry[:password]) ? entry[:password] : ""
    
    # Setup svn client
    repo resource_name do
      provider "repo_svn"
      repository url
      revision branch
      svn_username username
      svn_password password
      
      # persist true      # developed by RightScale (to contribute)
    end
  end
end
