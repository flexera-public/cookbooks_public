actions :create, :backup, :restore, :reset

attribute :cloud, :equal_to => [ "ec2", "rackspace" ], :required => true
attribute :lineage, :kind_of => String

attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String

# Volume provider only
attribute :volume_size, :kind_of => String
attribute :stripe_size, :kind_of => String

# Remote Object Store provider only
attribute :storage_type, :equal_to => [ "ros", "volume" ]
attribute :storage_account_id, :kind_of => String
attribute :storage_account_secret, :kind_of => String
attribute :storage_container, :kind_of => String


