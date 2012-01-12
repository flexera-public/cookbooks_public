# Cookbook Name:: db_postgres
# Definition:: db_postgres_restore
#
# Copyright (c) 2011 RightScale Inc
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

define :db_postgres_restore,  :url => nil, :branch => 'master', :user => nil, :credentials => nil, :file_path => nil, :schema_name => nil, :tmp_dir => '/tmp' do

  repo_params = params # see http://tickets.opscode.com/browse/CHEF-422

  dir = "#{params[:tmp_dir]}/db_postgres_restore"
  dumpfile = "#{dir}/#{params[:file_path]}"
  schema_name = params[:schema_name]

  # grab pg_dump file from remote repository
  repo_git_pull "Get pg_dump from git repository" do
    url repo_params[:url]
    branch repo_params[:branch]
    user repo_params[:user]
    dest dir
    cred repo_params[:credentials]
  end

  bash "unpack pg_dump file: #{dumpfile}" do
    not_if "echo \"select datname from pg_database\" | psql -h /var/run/postgresql -U postgres | grep -q  \"^#{schema_name}$\""
    user "postgres"
    cwd dir
    code <<-EOH
      set -e
      if [ ! -f #{dumpfile} ]
      then
        echo "ERROR: PostgreSQL dumpfile not found! File: '#{dumpfile}'"
        exit 1
      fi
      createdb -h /var/run/postgresql -U postgres #{schema_name}
      gunzip < #{dumpfile} | psql -h /var/run/postgresql -U postgres #{schema_name}
    EOH
  end

end
