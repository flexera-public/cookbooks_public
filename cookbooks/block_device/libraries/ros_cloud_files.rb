begin
  require 'rightscale_tools'
rescue LoadError
  Chef::Log.warn("Missing gem 'rightscale_tools'")
end

module RightScale
  module CloudStorage
    module CloudFiles
      def ros
        @@ros ||= ::RightScale::LvmRosCloudFiles.new(:rackspace_user => new_resource.storage_account_id, 
                                             :rackspace_secret => new_resource.storage_account_secret, 
                                             :mount_point => new_resource.mount_point, 
                                             :container => new_resource.storage_container, 
                                             :lineage => new_resource.lineage)
      end
    end
  end
end
