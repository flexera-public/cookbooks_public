#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_postgres_gzipfile_backup, :db_name => nil, :file_path => "/tmp/postgres_backup.gz" do
  bash "Write the postgres DB backup file" do
    user 'postgres'
	code <<-EOH
        pg_dump -h /var/run/postgresql -U postgres #{params[:db_name]} | gzip -c > #{params[:file_path]}
	EOH
  end
end
