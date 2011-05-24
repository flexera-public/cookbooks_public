include RightScale::Database::Helper

action :do_backup do
  @db = init(new_resource)
  block_device_args = { 
    :max_snapshots => new_resource.max_snapshots,
    :keep_dailies => new_resource.keep_daily,
    :keep_weeklies => new_resource.keep_weekly,
    :keep_monthlies => new_resource.keep_monthly,
    :keep_yearlies => new_resource.keep_yearly,
    
    :storage_account_type => new_resource.storage_account_type,  # "s3"|"cloudfiles" 
    :storage_account_id => new_resource.storage_account_id,
    :storage_account_secret => new_resource.storage_account_secret,
    :storage_account_container => new_resource.storage_account_container
  }
  @db.action_backup(new_resource.lineage, block_device_args)
end

action :do_restore do
  @db = init(new_resource)
  block_device_args = { 
    :storage_account_type => new_resource.storage_account_type,  # "s3"|"cloudfiles" 
    :storage_account_id => new_resource.storage_account_id,
    :storage_account_secret => new_resource.storage_account_secret,
    :storage_account_container => new_resource.storage_account_container
  }
  @db.action_restore(new_resource.lineage, block_device_args, new_resource.timestamp_override, new_resource.from_master, new_resource.force)
end