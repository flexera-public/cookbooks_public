actions :create, :backup #, :restore

attribute :block_device_type, :kind_of => String, :require => true
attribute :mount_point, :kind_of => String, :require => true

# Database settigns
attribute :host, :kind_of => String, :default => "localhost"
attribute :user, :kind_of => String, :default => "root"
attribute :password, :kind_of => String, :default => ""

# Backup/Restore arguments
attribute :lineage, :kind_of => String
attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String

# Remote Object Storage account info (S3, CloudFiles)
attribute :storage_account_id, :kind_of => String
attribute :storage_account_secret, :kind_of => String
attribute :storage_container, :kind_of => String




