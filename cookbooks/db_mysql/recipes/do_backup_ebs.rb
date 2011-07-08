db "/mnt/storage" do
  provider "db"

  storage_type "volume"
  cloud "ec2"

  lineage node[:db_mysql][:backup][:lineage]
  max_snapshots node[:db_mysql][:backup][:max_snapshots]
  keep_daily node[:db_mysql][:backup][:keep_daily]
  keep_weekly node[:db_mysql][:backup][:keep_weekly]
  keep_monthly node[:db_mysql][:backup][:keep_monthly]
  keep_yearly node[:db_mysql][:backup][:keep_yearly]
  action :backup
end
