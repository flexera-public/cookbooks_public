#
# Cookbook Name:: repo_git
# Provider:: repo_git
#
# Copyright (c) 2009 RightScale Inc
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

require 'uri'

action :pull do
  my_resource = new_resource # limitation of current LWRP implementation 
  
  # include the public recipe to install git
  include_recipe "git"
   
  # add repository credentials
  keyfile = nil
  if "#{my_resource.cred}" != ""
    keyfile = "/tmp/gitkey"
    bash 'create_temp_git_ssh_key' do
      code <<-EOH
        echo -n '#{my_resource.cred}' > #{keyfile}
	      chmod 700 #{keyfile}
        echo 'exec ssh -oStrictHostKeyChecking=no -i #{keyfile} "$@"' > #{keyfile}.sh
	      chmod +x #{keyfile}.sh
      EOH
    end
  end 

  # pull repo (if exist)
  ruby "pull-exsiting-local-repo" do
    cwd my_resource.dest
    only_if do File.directory?(my_resource.dest) end
    code <<-EOH
      puts "Updateing existing repo at #{my_resource.dest}"
      ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
      puts `git pull` 
    EOH
  end
  
  # clone repo (if not exist)
  ruby "create-new-local-repo" do
    not_if do File.directory?(my_resource.dest) end
    code <<-EOH
      puts "Creating new repo at #{my_resource.dest}"
      ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
      puts `git clone #{my_resource.url} -- #{my_resource.dest}`

      if "#{my_resource.branch}" != "master" 
	      dir = "#{my_resource.dest}"
        Dir.chdir(dir) 
        puts `git checkout --track -b #{my_resource.branch} origin/#{my_resource.branch}`
      end
    EOH
  end

  # delete SSH key & clear GIT_SSH
  if my_resource.cred != nil
     bash 'delete_temp_git_ssh_key' do
       code <<-EOH
         rm -f #{keyfile}
         rm -f #{keyfile}.sh
       EOH
     end
  end

end
