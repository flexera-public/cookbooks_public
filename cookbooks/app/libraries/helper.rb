#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module App
    module Helper
      
      # Return the IP address of the interface that this application server 
      # listens on.
      #
      # == Parameters 
      # private_ips(Array):: List of private ips assigned to the application server
      # public_ips(Array):: List of public ips assigned to the application server
      #
      # == Returns
      # String:: IP Address 
      #
      # == Raise
      # RuntimeError:: If nether a valid private nor public ip can be found
      def self.bind_ip(private_ips = [ ], public_ips = [ ])
        ip = nil
        if private_ips && private_ips.size > 0
          ip = private_ips[0] # default to first private ip
        elsif public_ips && public_ips.size > 0
          ip = public_ips[0]  # default to first public ip
        elseif
          raise "ERROR: cannot detect a bind address on this application server."
        end
        ip
      end
      
      # Return the port that this application server listens on
      def self.bind_port()
        node[:app][:port]
      end

      # Returns array from a comma seperated list
      def vhosts(vhost_list)
        return vhost_list.gsub(/\s+/, "").split(",").uniq.each
      end

    end
  end
end
