include RightScale::Database::Helper

action :stop do
  @db = init(new_resource)
  @db.stop
end

action :start do
  @db = init(new_resource)
  @db.start
end

action :move_data_dir do
  @db = init(new_resource)
  @db.move_data_dir
end

action :reset do
  @db = init(new_resource)
  @db.reset
end
