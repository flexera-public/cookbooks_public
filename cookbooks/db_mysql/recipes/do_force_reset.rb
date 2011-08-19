
db "/mnt/storage" do
  provider "db"
  cloud node[:cloud][:provider]
  storage_type node[:db_mysql][:backup][:storage_type] # "volume" or "ros"
  lineage node[:db_mysql][:backup][:lineage] 
  action :reset
end
