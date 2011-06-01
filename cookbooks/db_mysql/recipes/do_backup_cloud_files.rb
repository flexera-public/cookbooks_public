database "/mnt/storage" do
  provider "database"

  storage_type "ros"
  cloud "rackspace"

  lineage node[:db_mysql][:backup][:lineage]
  storage_account_id node[:db_mysql][:backup][:storage_account_id]
  storage_account_secret node[:db_mysql][:backup][:storage_account_secret]
  storage_container node[:db_mysql][:backup][:storage_container]
  action :backup
end
