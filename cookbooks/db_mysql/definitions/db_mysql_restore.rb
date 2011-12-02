#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_restore,  :url => nil, :branch => 'master', :user => nil, :credentials => nil, :file_path => nil, :schema_name => nil, :tmp_dir => '/tmp' do

  repo_params = params # see http://tickets.opscode.com/browse/CHEF-422
  
  dir = "#{params[:tmp_dir]}/db_mysql_restore"
  dumpfile = "#{dir}/#{params[:file_path]}"
  schema_name = params[:schema_name]

  # grab mysqldump file from remote repository
  repo_git_pull "Get mysqldump from git repository" do
    url repo_params[:url]
    branch repo_params[:branch] 
    user repo_params[:user]
    dest dir
    cred repo_params[:credentials]
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
