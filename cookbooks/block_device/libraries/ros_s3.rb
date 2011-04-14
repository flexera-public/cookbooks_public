begin
  require 'rightscale_tools'
rescue LoadError
  Chef::Log.warn("Missing gem 'rightscale_tools'")
end

module RightScale
  module CloudStorage
    module S3
      def ros
        @@ros ||= ::RightScale::LvmRosS3.new(:aws_access_key_id => new_resource.storage_account_id, 
                                             :aws_secret_access_key => new_resource.storage_account_secret, 
                                             :mount_point => new_resource.mount_point, 
                                             :container => new_resource.storage_container, 
                                             :lineage => new_resource.lineage)
      end
    end
  end
end
