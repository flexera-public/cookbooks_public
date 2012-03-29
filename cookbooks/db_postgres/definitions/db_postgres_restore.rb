#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
