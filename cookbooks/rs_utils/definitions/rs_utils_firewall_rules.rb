#
# Cookbook Name:: lb_haproxy
# Recipe:: do_attach_request
#
# Copyright 2009, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#
define :rs_utils_firewall_rules, :machine_tag => nil, :port => nil, :enable => true, :collection => "clients" do
  port = params[:port] ? params[:port] : params[:name]
  to_enable = params[:enable]
  tag = params[:machine_tag]
  collection_name = params[:collection]

  # Tell user what is going on
  msg = "#{to_enable ? "Enabling" : "Disabling"} firewall rule for port #{port}"
  msg << " on servers with tag #{tag}." if tag
  log msg

  if node[:rs_utils][:firewall][:enabled] == "true" 

    r = server_collection collection_name do
      tags tag
      action :nothing
    end
    r.run_action(:load)

    # Register all currently active app servers
    valid_ip_regex = '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
    @node[:server_collection][collection_name].each do |_, tags|
      tags.detect { |t| t =~ /^server:private_ip=(#{valid_ip_regex})$/ }
      client_ip = Regexp.last_match[1]
    
      rs_utils_firewall_rule port do
        ip_addr client_ip
        enable to_enable
      end
    end

  else 
    log "Firewall not enabled. Not adding rule for #{port}."
  end

end
