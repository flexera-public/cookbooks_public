database "/mnt/storage" do
  provider "database"

  storage_type "volume"
  cloud "ec2"

  lineage node[:db_mysql][:backup][:lineage]
  action :restore
end

include_recipe "db_mysql::do_symlink_datadir"
