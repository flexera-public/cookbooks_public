#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.



# Add actions to @action_list array.
# Used to allow comments between entries.
def self.add_action(sym)
  @action_list ||= Array.new
  @action_list << sym unless @action_list.include?(sym)
  @action_list
end

# = Database Attributes
# Below are the attributes defined by the db resource interface.
# == General options

#
attribute :user, :kind_of => String, :default => "root"
attribute :password, :kind_of => String, :default => ""
attribute :data_dir, :kind_of => String, :default => "/mnt/storage"

# == Backup/Restore options::


attribute :lineage, :kind_of => String
attribute :force, :kind_of => String, :default => "false"
attribute :timestamp_override, :kind_of => String, :default => nil
attribute :from_master, :kind_of => String, :default => nil

# == Privilege options


attribute :privilege, :equal_to => [ "administrator", "user" ], :default => "administrator"
attribute :privilege_username, :kind_of => String
attribute :privilege_password, :kind_of => String
attribute :privilege_database, :kind_of => String, :default => "*.*" # All databases

# == Firewall options


attribute :enable, :equal_to => [ true, false ], :default => true
attribute :ip_addr, :kind_of => String
attribute :machine_tag, :kind_of => String, :regex => /^([^:]+):(.+)=.+/

# == Import/Export options


attribute :dumpfile, :kind_of => String
attribute :db_name, :kind_of => String



add_action :stop                  


add_action :start                 


add_action :status                


add_action :lock       


add_action :unlock


add_action :reset


add_action :firewall_update


add_action :firewall_update_request
         

add_action :move_data_dir      



add_action :generate_dump_file


add_action :restore_from_dump_file


add_action :pre_backup_check 


add_action :post_backup_cleanup


# TODO
add_action :write_backup_info
 

add_action :pre_restore_check


add_action :post_restore_cleanup


add_action :set_privileges


add_action :install_client


add_action :install_server


add_action :setup_monitoring


add_action :enable_replication

# == Promote
# TODO

add_action :promote


# TODO
add_action :grant_replication_slave

actions @action_list

