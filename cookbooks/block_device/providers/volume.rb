include RightScale::BlockDeviceHelper

action :create do
  device = init("volume", new_resource)
  create_options = {
    :volume_size => new_resource.volume_size,
    :stripe_size => new_resource.stripe_size
  }
  device.action_create(create_options)
end

action :backup do
  device = init("volume", new_resource)
  backup_options = { 
    :max_snapshots => new_resource.max_snapshots,
    :keep_dailies => new_resource.keep_daily,
    :keep_weeklies => new_resource.keep_weekly,
    :keep_monthlies => new_resource.keep_monthly,
    :keep_yearlies => new_resource.keep_yearly 
  }
  device.action_backup(new_resource.lineage, backup_options)
end


action :restore do
  device = init("volume", new_resource)
  restore_args = { 
    # TODO :lineage_override => ""
    # TODO :timestamp_override => "" 
  }
  device.action_restore(new_resource.lineage, restore_args)
end

action :reset do
  device = init("volume", new_resource)
  device.action_reset
end
