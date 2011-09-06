# Cookbook Name:: app
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

    end
  end
end
