actions :create, :backup, :restore, :reset

attribute :cloud, :kind_of => String, :required => true
attribute :lineage, :kind_of => String

# Volume
attribute :volume_size, :kind_of => String
attribute :stripe_size, :kind_of => String
attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String

# Remote Object Store
attribute :storage_account_id, :kind_of => String
attribute :storage_account_secret, :kind_of => String
attribute :storage_container, :kind_of => String

# not gonna force any options :required => true here yet .. 
