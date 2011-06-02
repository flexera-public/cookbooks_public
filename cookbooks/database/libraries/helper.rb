module RightScale
  module Database
    module Helper
      
      def init(new_resource)
        begin
          require 'rightscale_tools'
        rescue LoadError
          Chef::Log.warn("This database cookbook requires our premium 'rightscale_tools' gem. Please contact Rightscale to upgrade your account.")
        end
        mount_point = new_resource.name
        block_device = RightScale::BlockDevice.new(mount_point, new_resource.cloud, new_resource.storage_type)
        #RightScale::Tools::Database.new(block_device, new_resource.user, new_resource.password, new_resource.db_type, Chef::Log)
        RightScale::Tools::Database.new(block_device, new_resource.user, new_resource.password, :mysql, Chef::Log)
      end

      
      def restore_args(new_resource)
        lineage = new_resource.lineage
        raise "ERROR: you must specify a lineage for restore!" unless lineage
        {
          :lineage => lineage,
          :new_size_gb => new_resource.new_size_gb,
          :from_master => new_resource.from_master,
          :timestamp_override => new_resource.timestamp_override
        }
      end
      
 
    end
  end
end
