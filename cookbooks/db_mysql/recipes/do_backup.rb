db "/mnt/storage" do
  provider "db"
  
  storage_type node[:db_mysql][:backup][:storage_type]
  cloud node[:cloud][:provider]
  
  # Database settings
  host = node[:db_mysql][:fqdn]  
  user = node[:db_mysql][:admin_user]
  password = node[:db_mysql][:admin_password] 

  # Backup/Restore arguments
  lineage node[:db_mysql][:backup][:lineage]  
  max_snapshots node[:db_mysql][:backup][:max_snapshots]
  keep_daily node[:db_mysql][:backup][:keep_daily]
  keep_weekly node[:db_mysql][:backup][:keep_weekly]
  keep_monthly node[:db_mysql][:backup][:keep_monthly]
  keep_yearly node[:db_mysql][:backup][:keep_yearly]
  
  # Remote Object Storage account info (S3, CloudFiles)
  rackspace_user node[:db_mysql][:backup][:rackspace_user]
  rackspace_secret node[:db_mysql][:backup][:rackspace_secret]
  aws_access_key_id node[:db_mysql][:backup][:aws_access_key_id]
  aws_secret_access_key node[:db_mysql][:backup][:aws_secret_access_key]
  storage_container node[:db_mysql][:backup][:storage_container]
    
  action :backup
end
