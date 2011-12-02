#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_gzipfile_restore, :db_name => nil, :file_path => nil do
  bash "(Over)Write #{params[:db_name]} db with data from the backup" do
    code <<-EOF
  mysqladmin -uroot -f drop #{params[:db_name]}
  mysqladmin -uroot create #{params[:db_name]}
  gunzip < #{params[:file_path]} | mysql -u root #{params[:db_name]}
    EOF
  end
end
