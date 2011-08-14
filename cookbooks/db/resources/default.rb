actions [
  :stop, 
  :start, 
  :status, 
  :lock,
  :unlock,
  :move_data_dir, 
  :reset, 
  :pre_restore_check, 
  :restore, 
  :post_restore_cleanup,
  :pre_backup_check, 
  :backup, 
  :post_backup_cleanup,
  :set_privileges
]

# Database options
attribute :user, :kind_of => String, :default => "root"
attribute :password, :kind_of => String, :default => ""
attribute :data_dir, :kind_of => String, :default => "/mnt/storage"
attribute :type, :equal_to => [ "mysql" ], :default => "mysql"

# Backup/Restore options
attribute :lineage, :kind_of => String
attribute :force, :kind_of => String, :default => "false"
attribute :timestamp_override, :kind_of => String, :default => nil
attribute :from_master, :kind_of => String, :default => nil

# Privilege options
attribute :privilege, :equal_to => [ "administrator", "user" ], :default => "administrator"
attribute :privilege_username, :kind_of => String
attribute :privilege_password, :kind_of => String
attribute :privilege_database, :kind_of => String, :default => "*.*" # All databases
