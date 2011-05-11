begin
  require 'rightscale_tools'
rescue LoadError
  Chef::Log.warn("Missing gem 'rightscale_tools'")
end


module RightScale
  module BlockDevice
    module Helper

      def init(type, new_resource)      
        mount_point = new_resource.name
        ::RightScale::BlockDevice.new(mount_point, new_resource.cloud, type)
      end
      
    end
  end
end
