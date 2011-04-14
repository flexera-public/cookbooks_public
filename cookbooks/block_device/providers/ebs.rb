include RightScale::CloudStorage::Ebs

action :create do
  # TODO: this might be required for convergence ..
  ros.ros.execute_terminate_volumes

  ros.action_create(new_resource.volume_size, new_resource.stripe_size)
end

action :backup do
  backup_options = { :lineage => new_resource.lineage,
                     :max_snapshots => new_resource.max_snapshots,
                     :keep_dailies => new_resource.keep_daily,
                     :keep_weeklies => new_resource.keep_weekly,
                     :keep_monthlies => new_resource.keep_monthly,
                     :keep_yearlies => new_resource.keep_yearly 
  }
 
  ros.action_backup(backup_options)
end

action :restore do
  restore_args = { :lineage => new_resource.lineage }
  # TODO restore_args[:timestamp_override] = 
  ros.action_restore(restore_args)
end

#def load_current_resource
#  @mysqldb = Chef::Resource::MysqlDatabase.new(new_resource.name)
#  @mysqldb.database(new_resource.database)
#  exists = db.list_dbs.include?(new_resource.database)
#  @mysqldb.exists(exists)
#end


