begin
  require 'rightscale_tools'
rescue LoadError
  Chef::Log.warn("Missing gem 'rightscale_tools'")
end

module RightScale
  module CloudStorage
    module Ebs
      def ros
        @@ros ||= ::RightScale::LvmRosEbs.new(new_resource.mount_point)
      end
    end
  end
end
