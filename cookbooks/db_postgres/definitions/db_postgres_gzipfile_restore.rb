#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
