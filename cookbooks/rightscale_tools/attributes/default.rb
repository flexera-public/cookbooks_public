# setup_continuous_backups required attributes
set_unless[:rightscale_tools][:cron_backup_minute] = 5 + rand(54) # backup starts random time between 5-59
set_unless[:rightscale_tools][:cron_backup_hour] = rand(23) # once a day, random hour

user_set = true if rightscale_tools[:cron_backup_minute] && rightscale_tools[:cron_backup_hour]
set_unless[:rightscale_tools][:cron_backup_minute] = 5 + rand(54) # backup starts random time between 5-59
