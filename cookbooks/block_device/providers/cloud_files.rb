include RightScale::CloudStorage::CloudFiles

action :create do
  ros.action_create(new_resource.volume_size, new_resource.stripe_size)
  # TODO: RAX requires different LVM setup ..
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
  # TODO restore_args[:timestamp_override] = 
  ros.action_restore
end

action :reset do
# TODO: yeah .. some naming strangeness here
  ros.ros.disk.umount_snapshot
  ros.ros.disk.umount
  ros.ros.disk.disable_volume
  ros.ros.disk.lvremove
  ros.ros.disk.vgremove
  ros.ros.disk.pvremove
end
