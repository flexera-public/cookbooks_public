
module RightScale
  module Database
    module Helper
      
      def is_pristine?(db)
        db.is_mysql_pristine?(nil, { :data_dir => db.data_dir } ) 
      end    
      
      def init(new_resource)

        begin
          require 'rightscale_tools'
        rescue LoadError
          Chef::Log.warn("This database cookbook requires our premium 'rightscale_tools' gem. Please contact Rightscale to upgrade your account.")
        end

        bd_type = new_resource.block_device_type 
        bd_args = block_device_args(bd_type, new_resource)
        db_args = database_args(new_resource)
        RightScale::Tools::Database.new(db_args, bd_type, bd_agrs)
      end

      def restore_args(new_resource)
        lineage = new_resource.lineage
        raise "ERROR: you must specify a lineage for backup!" unless lineage
        {
          :lineage => lineage,
          :max_snaps => new_resource.max_snapshots,
          :keep_dailies => new_resource.keep_dailies,
          :keep_weeklies => new_resource.keep_weeklies,
          :keep_monthlies => new_resource.keep_monthlies,
          :keep_yearlies => new_resource.keep_yearlies,
          :force => new_resource.force
        }
      end
      
      def restore_args(new_resource)
        lineage = new_resource.lineage
        raise "ERROR: you must specify a lineage for restore!" unless lineage
        {
          :lineage => lineage,
          :new_size_gb => new_resource.new_size_gb,
          :from_master => new_resource.from_master,
          :timestamp => new_resource.timestamp
        }
      end
      
    private
    
      def database_args(new_resource)
        { 
          :user => new_resource.user,
          :password => new_resource.password,
          :mount_point => new_resource.mount_point,
          :db_type => new_resource.db_type,
          :logger => Chef::Log 
        }
      end
    
      def block_device_args(block_device_type, new_resource)
        case block_device_type
        when :ebs
          block_device_args = {
        
          }
        when :cloudfiles
          block_device_args = {
        
          }
        when :cloudfiles
          block_device_args = {
        
          }
        else
          raise "ERROR: unsupported block_device_type specified! (type: #{block_device_type})"
        end
      end
      
    end
  end
end