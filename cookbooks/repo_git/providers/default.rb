#
# Cookbook Name:: repo_git
# Provider:: repo_git
#
# Copyright (c) 2020 RightScale Inc
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
 
  # add ssh key and exec script
  keyfile = nil
  keyname = new_resource.ssh_key
  if "#{keyname}" != ""
    keyfile = "/tmp/gitkey"
    bash 'create_temp_git_ssh_key' do
      code <<-EOH
        echo -n '#{keyname}' > #{keyfile}
        chmod 700 #{keyfile}
        echo 'exec ssh -oStrictHostKeyChecking=no -i #{keyfile} "$@"' > #{keyfile}.sh
        chmod +x #{keyfile}.sh
      EOH
    end
  end 

  # pull repo (if exist)
  ruby_block "Pull existing git repository at #{new_resource.destination}" do
    only_if do ::File.directory?(new_resource.destination) end
    block do
      Dir.chdir new_resource.destination
      puts "Updating existing repo at #{new_resource.destination}"
      ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
      puts `git pull` 
    end
  end

  # clone repo (if not exist)
  ruby_block "Clone new git repository at #{new_resource.destination}" do
    not_if do ::File.directory?(new_resource.destination) end
    block do
      puts "Creating new repo at #{new_resource.destination}"
      ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
      puts `git clone #{new_resource.repository} -- #{new_resource.destination}`
      branch = new_resource.revision
      if "#{branch}" != "master" 
        dir = "#{new_resource.destination}"
        Dir.chdir(dir) 
        puts `git checkout --track -b #{branch} origin/#{branch}`
      end
    end
  end

  # delete SSH key & clear GIT_SSH
  if keyfile != nil
     bash 'delete_temp_git_ssh_key' do
       code <<-EOH
         rm -f #{keyfile}
         rm -f #{keyfile}.sh
       EOH
     end
  end
 
end
