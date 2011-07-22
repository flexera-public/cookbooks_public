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
  module System
    module Helper

      # Calculates every 15 minute shedule for cron minute setting 
      # Uses a random start offset -- to avoid all systems from
      # reconverging at the same time.
      #
      # Returns: String
      def self.randomize_reconverge_minutes
        shed_string = ""
        s = rand(15) # calc random start minute
        4.times do |q| 
          shed_string << "," unless q == 0
          shed_string << "#{s + (q*15)}" 
        end
        shed_string.strip
      end

      # Use the server_collection resource programatically
      # FIXME: This is highly dependent on Chef version      
      def self.requery_server_collection(tag, collection_name, node, run_context)
        resrc = Chef::Resource::ServerCollection.new(collection_name)
        resrc.tags tag
        provider = nil      
        if (Chef::VERSION =~ /0\.9/) # provider signature changed in Chef 0.9
          provider = Chef::Provider::ServerCollection.new(resrc, run_context)
        else 
          provider = Chef::Provider::ServerCollection.new(node, resrc)
        end
        provider.send("action_load")
      end
            
      # Use the template resource programatically
      # FIXME: This is highly dependent on Chef version      
      def self.run_template(target_file, source, cookbook, variables, enable, command, node, run_context)
        resrc = Chef::Resource::Template.new(target_file)
        resrc.source source
        resrc.cookbook cookbook
        resrc.variables variables
        resrc.backup false
        #resrc.notifies notify_action, notify_resources
        
        if (Chef::VERSION =~ /0\.9/) # provider signature changed in Chef 0.9
          provider = Chef::Provider::Template.new(resrc, run_context)
        else 
          provider = Chef::Provider::Template.new(node, resrc)
        end
        provider.load_current_resource
               
        if enable
          provider.send("action_create")
        else
          provider.send("action_delete")
        end
        
        Chef::Log.info `/usr/sbin/rebuild-iptables` if resrc.updated
      end
      
      def self.calculate_exponential_backoff(value)
        ((value == 1) ? 2 : (value*value)) 
      end

    end
  end
end