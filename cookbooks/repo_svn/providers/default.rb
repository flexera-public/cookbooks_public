#
# Cookbook Name:: repo_svn
# Provider:: repo_svn
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

action :pull do
 
  # setup parameters 
  password = new_resource.svn_password
  branch = new_resource.revision
  params = "--no-auth-cache --non-interactive"
  params << " --username #{new_resource.svn_username} --password #{password}" if "#{password}" != ""
  params << " --revision #{branch}" if "#{branch}" != ""

  # pull repo (if exist)
  ruby_block "Pull existing Subversion repository at #{new_resource.destination}" do
    only_if do ::File.directory?(new_resource.destination) end
    block do
      Dir.chdir new_resource.destination
      Chef::Log.info "Updating existing repo at #{new_resource.destination}"
      Chef::Log.info `svn update #{params} #{new_resource.repository} #{new_resource.destination}` 
    end
  end

  # clone repo (if not exist)
  ruby_block "Checkout new Subversion repository to #{new_resource.destination}" do
    not_if do ::File.directory?(new_resource.destination) end
    block do
      Chef::Log.info "Creating new repo at #{new_resource.destination} #{params} #{new_resource.repository}"
      Chef::Log.info `svn checkout #{params} #{new_resource.repository} #{new_resource.destination}`
    end
  end
 
end
