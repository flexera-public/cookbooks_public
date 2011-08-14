include RightScale::Database::Helper

action :stop do
  @db = init(new_resource)
  @db.stop
end

action :start do
  @db = init(new_resource)
  @db.start
end

action :status do
	@db = init(new_resource)
	status = @db.status
	log "Database Status:\n#{status}"
end

action :lock do
  @db = init(new_resource)
  @db.unlock
end

action :unlock do
  @db = init(new_resource)
  @db.unlock
end

action :move_data_dir do
  @db = init(new_resource)
  @db.move_datadir
end

action :reset do
  @db = init(new_resource)
  @db.reset
end

action :pre_restore_check do
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

action :post_restore_cleanup do
  @db = init(new_resource)
  @db.symlink_datadir
  @db.post_restore_sanity_check
  @db.post_restore_cleanup
end

action :pre_backup_check do
  @db = init(new_resource)
  @db.pre_backup_check
end

action :post_backup_cleanup do
  @db = init(new_resource)
  @db.clean_backup_info
end

action :set_privileges do
  @db = init(new_resource)
  @db.set_privileges
end
