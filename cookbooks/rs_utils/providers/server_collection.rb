#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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

