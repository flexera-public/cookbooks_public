include RightScale::BlockDeviceHelper

action :create do
  device = init("ros", new_resource)
  device.action_create
end

action :backup do
  device = init("ros", new_resource)
  backup_options = { 
    :max_snapshots => new_resource.max_snapshots,
    :keep_dailies => new_resource.keep_daily,
    :keep_weeklies => new_resource.keep_weekly,
    :keep_monthlies => new_resource.keep_monthly,
    :keep_yearlies => new_resource.keep_yearly,
    
    :storage_type => new_resource.storage_type,  # "s3"|"cloudfiles" 
    :storage_account_id => new_resource.storage_account_id,
    :storage_account_secret => new_resource.storage_account_secret,
    :storage_container => new_resource.storage_container
  }
  device.action_backup(new_resource.lineage, backup_options)
end

action :restore do
  device = init("ros", new_resource)
  restore_args = { 
    # TODO :lineage_override => ""
    # TODO :timestamp_override => "" 
    :storage_type => new_resource.storage_type,  # "s3"|"cloudfiles" 
    :storage_account_id => new_resource.storage_account_id,
    :storage_account_secret => new_resource.storage_account_secret,
    :storage_container => new_resource.storage_container
  }
  device.action_restore(new_resource.lineage, restore_args)
end

action :reset do
  device = init("ros", new_resource)
  device.action_reset
end
