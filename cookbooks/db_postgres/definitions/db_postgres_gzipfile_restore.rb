# Cookbook Name:: db_postgres
# Recipe: db_postgres_gzipfile_restore
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

define :db_postgres_gzipfile_restore, :db_name => nil, :file_path => nil do
  bash "(Over)Write #{params[:db_name]} db with data from the backup" do
  user 'postgres'
    code <<-EOF
      dropdb -h /var/run/postgresql -U postgres #{params[:db_name]}
      createdb -h /var/run/postgresql -U postgres #{params[:db_name]}
      gunzip -c #{params[:file_path]} | psql -h /var/run/postgresql -U postgres #{params[:db_name]}  
    EOF
  end
end
