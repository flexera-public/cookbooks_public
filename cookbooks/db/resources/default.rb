actions :stop, :start, :move_data_dir, :reset

# Database settings
#attribute :host, :kind_of => String, :default => "localhost"
attribute :user, :kind_of => String, :default => "root"
attribute :password, :kind_of => String, :default => ""
attribute :data_dir, :kind_of => String, :default => "/mnt/storage"
attribute :type, :equal_to => [ :mysql ], :default => :mysql


# Backup/Restore settings
attribute :lineage, :kind_of => String
attribute :force, :kind_of => String, :default => "false"
attribute :timestamp_override, :kind_of => String, :default => nil
attribute :from_master, :kind_of => String, :default => nil


