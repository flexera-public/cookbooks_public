db "/mnt/storage" do
  provider "db"

  storage_type "volume"
  cloud "ec2"

  lineage node[:db_mysql][:backup][:lineage]
  action :restore
end

