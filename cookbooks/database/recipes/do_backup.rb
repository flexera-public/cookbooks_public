database "do_backup" do
  provider "database"
  
  mount_point node[:db_mysql][:mount_point]
  
  # Database settings
  host = node[:db_mysql][:host]  
  user = node[:db_mysql][:user] 
  password = node[:db_mysql][:password] 

  # Backup/Restore arguments
  lineage node[:db_mysql][:lineage]  
  max_snapshots node[:db_mysql][:max_snapshots]
  keep_daily node[:db_mysql][:keep_daily]
  keep_weekly node[:db_mysql][:keep_weekly]
  keep_monthly node[:db_mysql][:keep_monthly]
  keep_yearly node[:db_mysql][:keep_yearly]

  # Volume Storage only (i.e. EBS)
  volume_size "1"
  stripe_size "1"
  
  # Remote Object Storage account info (S3, CloudFiles)
  storage_account_id node[:db_mysql][:storage_account_id]
  storage_account_secret node[:db_mysql][:storage_account_secret]
  storage_container node[:db_mysql][:storage_container]
    
  action :backup
end