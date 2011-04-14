actions :create, :backup, :restore, :reset
attribute :mount_point, :kind_of => String
attribute :volume_size, :kind_of => String
attribute :stripe_size, :kind_of => String
attribute :surround_with, :kind_of => String, :default => "none"
attribute :lineage, :kind_of => String
attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String
attribute :storage_account_id, :kind_of => String
attribute :storage_account_secret, :kind_of => String
attribute :storage_container, :kind_of => String

# not gonna force any options :required => true here yet .. 
