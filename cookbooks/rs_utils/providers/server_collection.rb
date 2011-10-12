# Cookbook Name:: rs_utils
# Provider:: rs_utils_server_collection
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

require 'timeout'

action :load do
  collection_resource = server_collection new_resource.name do
    tags new_resource.tags
    agent_ids new_resource.agent_ids
    action :nothing
  end

  begin
    Timeout::timeout(new_resource.timeout) do
      all_tags = new_resource.tags.collect
      all_tags += new_resource.secondary_tags.collect if new_resource.secondary_tags
      delay = 1
      while true
        collection_resource.run_action(:load)
        collection = node[:server_collection][new_resource.name]

        break if new_resource.empty_ok && collection.empty?
        break if !collection.empty? && collection.all? do |id, tags|
          all_tags.all? do |prefix|
            tags.detect {|tag| RightScale::Utils::Helper.matches_tag_wildcard?(prefix, tag)}
          end
        end

        delay = RightScale::System::Helper.calculate_exponential_backoff(delay)
        Chef::Log.info "not all tags for #{new_resource.tags.inspect} exist; retrying in #{delay} seconds..."
        sleep delay
      end
    end
  rescue Timeout::Error => e
    raise "ERROR: timed out trying to find servers tagged with #{new_resource.tags.inspect}"
  end
end
