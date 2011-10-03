TIMEOUT_SEC = 4 * 60 # 4min

define :wait_for_tag, :collection_name => nil, :should_exist => true, :timeout => TIMEOUT_SEC do

  tag = params[:name]
  collection = params[:collection_name]
  timeout = params[:timeout]
  should_exist = params[:should_exist]
  state = should_exist ? "exist" : "vanish"

  server_collection_resource = server_collection collection do
    tags tag
    action :nothing
  end

  ruby_block "wait for tag #{state}." do
    block do
      require 'timeout'
    
      done = false
      begin
        status = Timeout::timeout(timeout) do
          until done
            server_collection_resource.run_action("load")
            h = node[:server_collection][collection]
            tags = h[h.keys[0]]
            done = true if (tags && should_exist || tags == nil && !should_exist)
            unless done
              sleep 10
              Chef::Log.info "  Waiting for tag #{state}.  Retry..."
            end
          end
        end
      rescue Timeout::Error => e
        raise "ERROR: right_link_tag resource failed to remove a tag after #{timeout/60} minutes."
      end
      Chef::Log.info "#{tag} tag #{state}."
    end
  end
  
end
