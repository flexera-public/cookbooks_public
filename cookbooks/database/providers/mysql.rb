include RightScale::Database::Helper

action :create do
  @db = init(new_resource)
  true
end

action :do_backup do
  @db = init(new_resource)
  args = backup_args(new_resource)
  @db.action_backup(args)
end

action :do_restore do
  #TODO
end