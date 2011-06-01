actions :backup, :restore, :create

# Database settings
attribute :host, :kind_of => String, :default => "localhost"
attribute :user, :kind_of => String, :default => "root"
attribute :password, :kind_of => String, :default => ""

# Backup/Restore settings
attribute :lineage, :kind_of => String
attribute :cloud, :equal_to => [ "ec2", "rackspace" ], :required => true
attribute :force, :kind_of => String, :default => "false"
attribute :timestamp_override, :kind_of => String, :default => nil
attribute :from_master, :kind_of => String, :default => nil

attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String

# Remote Object Store backup/restore only
attribute :storage_type, :equal_to => [ "ros", "volume" ]
attribute :storage_account_id, :kind_of => String
attribute :storage_account_secret, :kind_of => String
attribute :storage_container, :kind_of => String




