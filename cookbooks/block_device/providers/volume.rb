
action :create do
  device = init("volume", new_resource)
  create_options = {
    :volume_size => new_resource.volume_size,
    :stripe_count => new_resource.stripe_count
  }
  device.action_create(create_options)
end


action :backup do
  device = init("volume", new_resource)
  backup_options = { 
    :lineage => new_resource.lineage,
    :max_snapshots => new_resource.max_snapshots,
    :keep_dailies => new_resource.keep_daily,
    :keep_weeklies => new_resource.keep_weekly,
    :keep_monthlies => new_resource.keep_monthly,
    :keep_yearlies => new_resource.keep_yearly 
  }
  device.action_backup(backup_options)
end


action :restore do
  device = init("volume", new_resource)
  restore_args = { 
    :lineage => new_resource.lineage 
    # TODO :lineage_override => ""
    # TODO :timestamp_override => "" 
  }
  device.action_restore(restore_args)
end


