
database "/mnt/storage" do
  provider "database"
  cloud node[:cloud][:provider]
  storage_type node[:db_mysql][:backup][:storage_type] # "volume" or "ros"
  action :reset
end
