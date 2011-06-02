database "/mnt/storage" do
  provider "database"

  storage_type "ros"
  cloud "rackspace"

  lineage node[:db_mysql][:backup][:lineage]
  rackspace_user node[:db_mysql][:backup][:rackspace_user]
  rackspace_secret node[:db_mysql][:backup][:rackspace_secret]
  storage_container node[:db_mysql][:backup][:storage_container]
  action :backup
end
