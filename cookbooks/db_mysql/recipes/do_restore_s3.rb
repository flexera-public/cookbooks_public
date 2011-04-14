database "/mnt/storage" do
  provider "database"

  storage_type "ros"
  cloud "ec2"

  aws_access_key_id node[:db_mysql][:backup][:aws_access_key_id]
  aws_secret_access_key node[:db_mysql][:backup][:aws_secret_access_key]
  storage_container node[:db_mysql][:backup][:storage_container]
  lineage node[:db_mysql][:backup][:lineage]
  action :restore
end 

