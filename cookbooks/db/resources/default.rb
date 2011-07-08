actions :backup, :restore, :create, :reset, :firewall_set, :firewall_set_request

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

# Volume provider only
attribute :volume_size, :kind_of => String
attribute :stripe_count, :kind_of => String
attribute :new_volume_size_in_gb, :kind_of => String

# Remote Object Store provider only
attribute :storage_type, :equal_to => [ "ros", "volume" ]
attribute :aws_access_key_id, :kind_of => String
attribute :aws_secret_access_key, :kind_of => String
attribute :rackspace_user, :kind_of => String
attribute :rackspace_secret, :kind_of => String

attribute :storage_container, :kind_of => String

# Firewall setttings
attribute :firewall_client_ip, :kind_of => String
attribute :firewall_client_tag, :kind_of => String
attribute :firewall_port_state, :equal_to => [ "open", "closed" ]
