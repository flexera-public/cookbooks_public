#
# Cookbook Name:: db_mysql
# Definition:: db_mysql_restore
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

define :db_mysql_restore,  :file_path => nil, :schema_name => nil, :tmp_dir => '/tmp' do

  repo_params = params # see http://tickets.opscode.com/browse/CHEF-422
  
  dir = "#{params[:tmp_dir]}/db_mysql_restore"
  dumpfile = "#{dir}/#{params[:file_path]}"
  schema_name = params[:schema_name]
  
  include_recipe "repo_git::default"  # this must run in the same converge until persistent resources are supported
  
  repo "default" do
    destination dir
    action :pull
  end

  bash "unpack mysqldump file: #{dumpfile}" do
    not_if "echo \"show databases\" | mysql | grep -q  \"^#{schema_name}$\""
    user "root"
    cwd dir
    code <<-EOH
      set -e
      if [ ! -f #{dumpfile} ] 
      then 
        echo "ERROR: MySQL dumpfile not found! File: '#{dumpfile}'" 
        exit 1
      fi 
      mysqladmin -u root create #{schema_name} 
      gunzip < #{dumpfile} | mysql -u root -b #{schema_name}
    EOH
  end

end
