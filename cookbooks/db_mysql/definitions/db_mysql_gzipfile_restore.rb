define :db_mysql_gzipfile_restore, :db_name => nil, :file_path => nil do
  bash "(Over)Write #{params[:db_name]} db with data from the backup" do
    code <<-EOF
  mysqladmin -uroot -f drop #{params[:db_name]}
  mysqladmin -uroot create #{params[:db_name]}
  gunzip < #{params[:file_path]} | mysql -u root #{params[:db_name]}
    EOF
  end
end