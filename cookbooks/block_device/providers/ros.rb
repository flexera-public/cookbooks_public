
action :create do
  device = init("ros", new_resource)
  device.action_create
end


action :backup do
  device = init("ros", new_resource)
  backup_options = { 
    :lineage => new_resource.lineage,
    :max_snapshots => new_resource.max_snapshots,
    :keep_dailies => new_resource.keep_daily,
    :keep_weeklies => new_resource.keep_weekly,
    :keep_monthlies => new_resource.keep_monthly,
    :keep_yearlies => new_resource.keep_yearly 
    
    :storage_account_type => new_resource.storage_account_type  # "s3"|"cloudfiles" 
    :storage_account_id => new_resource.storage_account_id
    :storage_account_secret => new_resource.storage_account_secret
    :storage_account_container => new_resource.storage_account_container
  }
  device.action_backup(backup_options)
end


action :restore do
  device = init("ros", new_resource)
  restore_args = { 
    :lineage => new_resource.lineage 
    # TODO :lineage_override => ""
    # TODO :timestamp_override => "" 
    :storage_account_type => new_resource.storage_account_type  # "s3"|"cloudfiles" 
    :storage_account_id => new_resource.storage_account_id
    :storage_account_secret => new_resource.storage_account_secret
    :storage_account_container => new_resource.storage_account_container
  }
  device.action_restore(restore_args)
end




