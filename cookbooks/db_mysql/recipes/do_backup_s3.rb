database "/mnt/storage" do
  provider "database"

  storage_type "ros"
  cloud "ec2"

  lineage node[:db_mysql][:backup][:lineage]
  storage_account_id node[:db_mysql][:backup][:storage_account_id]
  storage_account_secret node[:db_mysql][:backup][:storage_account_secret]
  storage_container node[:db_mysql][:backup][:storage_container]
  max_snapshots node[:db_mysql][:backup][:max_snapshots]
  keep_daily node[:db_mysql][:backup][:keep_daily]
  keep_weekly node[:db_mysql][:backup][:keep_weekly]
  keep_monthly node[:db_mysql][:backup][:keep_monthly]
  keep_yearly node[:db_mysql][:backup][:keep_yearly]
  action :backup
end
