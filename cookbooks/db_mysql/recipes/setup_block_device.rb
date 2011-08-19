# Initialize the storage device
storage_type = node[:db_mysql][:backup][:storage_type] # "volume" or "ros"

db "/mnt/storage" do
  provider "db"
  storage_type node[:db_mysql][:backup][:storage_type] # "volume" or "ros"
  lineage node[:db_mysql][:backup][:lineage] 
  cloud node[:cloud][:provider]
  # volume only
  volume_size node[:db_mysql][:backup][:volume_size]
  stripe_count node[:db_mysql][:backup][:stripe_count]

  action :create
end

