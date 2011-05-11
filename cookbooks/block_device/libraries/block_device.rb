begin
  require 'rightscale_tools'
rescue LoadError
  Chef::Log.warn("Missing gem 'rightscale_tools'")
end


module RightScale
  module BlockDevice
    module Helper

      def init(type, new_resource)
        args = block_device_args(type)      
        mount_point = new_resource.name
        ::RightScale::BlockDevice.new(mount_point, new_resource.cloud, type, args)
      end
      
    private 
      
      def block_device_args(block_device_type, new_resource)
        case device_type
        when "volume"
          block_device_args = nil
        when "ros"
          block_device_args = {
              # Remote Object Storage account info (S3, CloudFiles)
              :storage_account_id => new_resource.storage_account_id,
              :storage_account_secret new_resource.storage_account_secret,
          }
        else
          raise "ERROR: unsupported block_device_type specified! (type: #{block_device_type})"
        end
        block_device_args
      end
    end
  end
end
