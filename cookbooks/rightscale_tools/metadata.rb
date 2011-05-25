maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures rightscale_tools"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe  "rightscale_tools::default", "installs rightscale_tools gem for use with backup/restore"
recipe  "rightscale_tools::force_reset", "umount and delete"

recipe  "rightscale_tools::create_lvm_device_s3", "creates ebs storage and mounts"
recipe  "rightscale_tools::create_lvm_device_ebs", "creates ebs storage and mounts"
recipe  "rightscale_tools::create_lvm_device_rackspace", "creates cloud_files storage and mounts"
recipe  "rightscale_tools::create_lvm_device", "creates storage and mounts based on cloud and storage_type"

recipe "rightscale_tools::do_backup_ebs","backup EBS storage"
recipe "rightscale_tools::do_restore_ebs","restore EBS storage"

recipe "rightscale_tools::do_backup_s3","backup S3 storage"
recipe "rightscale_tools::do_restore_s3","backup S3 storage"

recipe "rightscale_tools::do_backup_cloud_files", "backup cloud_files storage"
recipe "rightscale_tools::do_restore_cloud_files", "backup cloud_files storage"

recipe "rightscale_tools::setup_continuous_backups_s3", "CRON backup setup"
recipe "rightscale_tools::setup_continuous_backups_ebs", "CRON backup setup"
recipe "rightscale_tools::setup_continuous_backups_cloud_files", "CRON backup setup"

recipe "rightscale_tools::disable_continuous_backups_s3", "disable CRON backups"
recipe "rightscale_tools::disable_continuous_backups_ebs", "disable CRON backups"
recipe "rightscale_tools::disable_continuous_backups_cloud_files", "disable CRON backups"

all_recipes = [ "rightscale_tools::do_restore_s3", 
                "rightscale_tools::do_backup_s3", 
                "rightscale_tools::do_restore_ebs", 
                "rightscale_tools::do_backup_ebs", 
                "rightscale_tools::do_restore_cloud_files", 
                "rightscale_tools::do_backup_cloud_files", 
                "rightscale_tools::create_lvm_device_s3", 
                "rightscale_tools::create_lvm_device_ebs",
                "rightscale_tools::create_lvm_device_rackspace",
                "rightscale_tools::setup_continuous_backups_s3",
                "rightscale_tools::setup_continuous_backups_ebs", 
                "rightscale_tools::setup_continuous_backups_cloud_files", 
                "rightscale_tools::disable_continuous_backups_s3",
                "rightscale_tools::disable_continuous_backups_ebs",
                "rightscale_tools::disable_continuous_backups_cloud_files",
                "rightscale_tools::default" ]

backup_recipes = [ "rightscale_tools::do_restore_s3", 
                   "rightscale_tools::do_backup_s3", 
                   "rightscale_tools::do_restore_ebs", 
                   "rightscale_tools::do_backup_ebs", 
                   "rightscale_tools::do_restore_cloud_files", 
                   "rightscale_tools::do_backup_cloud_files"
]

all_recipes_require_storage_cred = ["rightscale_tools::do_restore_s3", 
                                    "rightscale_tools::do_backup_s3", 
                                    "rightscale_tools::do_restore_ebs", 
                                    "rightscale_tools::do_backup_ebs", 
                                    "rightscale_tools::do_restore_cloud_files", 
                                    "rightscale_tools::do_backup_cloud_files", 
                                    "rightscale_tools::create_lvm_device_s3", 
                                    "rightscale_tools::create_lvm_device_ebs",
                                    "rightscale_tools::create_lvm_device_rackspace"]

setup_cron_recipes = [
                "rightscale_tools::setup_continuous_backups_s3",
                "rightscale_tools::setup_continuous_backups_ebs", 
                "rightscale_tools::setup_continuous_backups_cloud_files"
                ]

attribute "rightscale_tools/storage_type",
  :display_name => "Block Device Storage Type",
  :description => "TODO",
  :choice => ["ebs", "s3", "cloudfiles"],
  :type => "string",
  :default => "ebs",
  :recipes => [ "rightscale_tools::create_lvm_device" ]

attribute "rightscale_tools/cron_backup_minute",
  :display_name => "Backup cron minute", 
  :description => "Defines the minute of the hour when the backup will be taken.",
  :required => false,
  :recipes => setup_cron_recipes

attribute "rightscale_tools/cron_backup_hour",
  :display_name => "Backup cron hour",
  :description => "Defines the hour when the backup will be taken.",
  :required => false,
  :recipes => setup_cron_recipes

attribute "rightscale_tools/storage_account_id",
  :display_name => "Remote Storage Account ID",
  :description => "The account ID that will be used to access the 'Remote Storage Container'.  For AWS, enter your AWS Access Key ID.  For Rackspace, enter your username.",
  :required => false,
  :recipes => all_recipes_require_storage_cred

attribute "rightscale_tools/storage_account_secret",
  :display_name => "Remote Storage Account Key",
  :description => "The account key that will be used to access the 'Remote Storage Container'.  For AWS, enter your AWS Secret Access Key.  For Rackspace, enter your API Key.",
  :required => false,
  :recipes => all_recipes_require_storage_cred
  
attribute "rightscale_tools/storage_container",
  :display_name => "Remote Storage Container",
  :description => "The location, directory, or bucket on the cloud's remote storage service in which files will be stored.  For AWS, enter an S3 bucket name.  For Rackspace, enter the container name.",
  :required => false,
  :recipes => all_recipes_require_storage_cred

attribute "rightscale_tools/lineage",
  :display_name => "Lineage",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "rightscale_tools/max_snapshots",
  :display_name => "Max Snapshots",
  :description => "",
  :required => false,
  :recipes => backup_recipes
  
attribute "rightscale_tools/keep_daily",
  :display_name => "Keep Daily Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes
  
attribute "rightscale_tools/keep_weekly",
  :display_name => "Keep Weekly Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "rightscale_tools/keep_monthly",
  :display_name => "Keep Monthly Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "rightscale_tools/keep_yearly",
  :display_name => "Keep Yearly Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes
