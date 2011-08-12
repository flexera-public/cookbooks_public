module RightScale
  module Database
    module Helper
      
      def init(new_resource)
        begin
          require 'rightscale_tools'
        rescue LoadError
          Chef::Log.warn("This database cookbook requires our premium 'rightscale_tools' gem.")
          Chef::Log.warn("Please contact Rightscale to upgrade your account.")
        end
        mount_point = new_resource.name
        RightScale::Tools::Database.factory(:mysql, new_resource.user, new_resource.password, mount_point, Chef::Log)
      end

    end
  end
end
