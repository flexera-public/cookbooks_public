maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures block_device"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe  "block_device::default", "create, format and mount block_device"
recipe  "block_device::do_force_reset", "umount and delete"

recipe  "block_device::setup_lvm_device_ec2_ephemeral", "creates ebs storage and mounts"
recipe  "block_device::setup_lvm_device_ebs", "creates ebs storage and mounts"
recipe  "block_device::setup_lvm_device_rackspace", "creates cloud_files storage and mounts"

recipe "block_device::do_backup_ebs","backup EBS storage"
recipe "block_device::do_restore_ebs","restore EBS storage"

recipe "block_device::do_backup_s3","backup S3 storage"
recipe "block_device::do_restore_s3","backup S3 storage"

recipe "block_device::do_backup_cloud_files", "backup cloud_files storage"
recipe "block_device::do_restore_cloud_files", "backup cloud_files storage"

recipe "block_device::setup_continuous_backups_s3", "CRON backup setup"
recipe "block_device::setup_continuous_backups_ebs", "CRON backup setup"
recipe "block_device::setup_continuous_backups_cloud_files", "CRON backup setup"

recipe "block_device::do_disable_continuous_backups_s3", "disable CRON backups"
recipe "block_device::do_disable_continuous_backups_ebs", "disable CRON backups"
recipe "block_device::do_disable_continuous_backups_cloud_files", "disable CRON backups"

all_recipes = [ "block_device::do_restore_s3", 
                "block_device::do_backup_s3", 
                "block_device::do_restore_ebs", 
                "block_device::do_backup_ebs", 
                "block_device::do_restore_cloud_files", 
                "block_device::do_backup_cloud_files", 
                "block_device::setup_lvm_device_ec2_ephemeral", 
                "block_device::setup_lvm_device_ebs",
                "block_device::setup_lvm_device_rackspace",
                "block_device::setup_continuous_backups_s3",
                "block_device::setup_continuous_backups_ebs", 
                "block_device::setup_continuous_backups_cloud_files", 
                "block_device::do_disable_continuous_backups_s3",
                "block_device::do_disable_continuous_backups_ebs",
                "block_device::do_disable_continuous_backups_cloud_files",
                "block_device::default" ]

backup_recipes = [ "block_device::do_restore_s3", 
                   "block_device::do_backup_s3", 
                   "block_device::do_restore_ebs", 
                   "block_device::do_backup_ebs", 
                   "block_device::do_restore_cloud_files", 
                   "block_device::do_backup_cloud_files"
]

all_recipes_require_storage_cred = ["block_device::do_restore_s3", 
                                    "block_device::do_backup_s3", 
                                    "block_device::do_restore_ebs", 
                                    "block_device::do_backup_ebs", 
                                    "block_device::do_restore_cloud_files", 
                                    "block_device::do_backup_cloud_files", 
                                    "block_device::setup_lvm_device_ec2_ephemeral", 
                                    "block_device::setup_lvm_device_ebs",
                                    "block_device::setup_lvm_device_rackspace"]

setup_cron_recipes = [
                "block_device::setup_continuous_backups_s3",
                "block_device::setup_continuous_backups_ebs", 
                "block_device::setup_continuous_backups_cloud_files"
                ]

attribute "block_device/cron_backup_minute",
  :display_name => "Backup cron minute", 
  :description => "Defines the minute of the hour when the backup will be taken.",
  :required => false,
  :recipes => setup_cron_recipes

attribute "block_device/cron_backup_hour",
  :display_name => "Backup cron hour",
  :description => "Defines the hour when the backup will be taken.",
  :required => false,
  :recipes => setup_cron_recipes

attribute "block_device/storage_account_id",
  :display_name => "Remote Storage Account ID",
  :description => "The account ID that will be used to access the 'Remote Storage Container'.  For AWS, enter your AWS Access Key ID.  For Rackspace, enter your username.",
  :required => false,
  :recipes => all_recipes_require_storage_cred

attribute "block_device/storage_account_secret",
  :display_name => "Remote Storage Account Key",
  :description => "The account key that will be used to access the 'Remote Storage Container'.  For AWS, enter your AWS Secret Access Key.  For Rackspace, enter your API Key.",
  :required => false,
  :recipes => all_recipes_require_storage_cred
  
attribute "block_device/storage_container",
  :display_name => "Remote Storage Container",
  :description => "The location, directory, or bucket on the cloud's remote storage service in which files will be stored.  For AWS, enter an S3 bucket name.  For Rackspace, enter the container name.",
  :required => false,
  :recipes => all_recipes_require_storage_cred

attribute "block_device/lineage",
  :display_name => "Lineage",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "block_device/max_snapshots",
  :display_name => "Max Snapshots",
  :description => "",
  :required => false,
  :recipes => backup_recipes
  
attribute "block_device/keep_daily",
  :display_name => "Keep Daily Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes
  
attribute "block_device/keep_weekly",
  :display_name => "Keep Weekly Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "block_device/keep_monthly",
  :display_name => "Keep Monthly Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "block_device/keep_yearly",
  :display_name => "Keep Yearly Backups",
  :description => "",
  :required => false,
  :recipes => backup_recipes

attribute "block_device/storage_type",
  :display_name => "Block Device Storage Type",
  :description => "Sets storage type to Volume (i.e.EBS) or Remote Object Store (i.e. s3, cloudfiles)",
  :choice => ["volume", "ros"],
  :type => "string",
  :required => true,
  :recipes => [ "block_device::default" ]

