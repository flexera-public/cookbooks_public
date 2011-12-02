#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_gzipfile_backup, :db_name => nil, :file_path => "/tmp/mysql_backup.gz" do
  bash "Write the mysql DB backup file" do
    code "mysqldump --single-transaction -u root #{params[:db_name]} | gzip -c > #{params[:file_path]}"
  end
end
