#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

require "timeout"

action :update do

  # Set local variables from attributes
  port = new_resource.port ? new_resource.port : new_resource.name
  raise "ERROR: port must be set" if port == ""
  protocol = new_resource.protocol
  to_enable = new_resource.enable
  ip_addr = new_resource.ip_addr
  machine_tag = new_resource.machine_tag
  ip_tag = "server:private_ip_0"
  collection_name = new_resource.collection

  # We only support ip_addr or tags, however, ip_addr defaults to 'any' so reconcile here
  ip_addr.downcase!
  ip_addr = nil if (ip_addr == "any") && machine_tag  # tags win, so clear 'any'
  raise "ERROR: ip_addr param cannot be used with machine_tag param." if machine_tag && ip_addr

  # Tell user what is going on
  msg = "#{to_enable ? "Enabling" : "Disabling"} firewall rule for port #{port}"
  msg << " only for address #{ip_addr}" if ip_addr
  msg << " on servers with tag #{machine_tag}" if machine_tag
  msg << " using protocol #{protocol}." if protocol
  log msg

  # Update rules
  unless node[:sys_firewall][:enabled] == "enabled"
    log "Firewall not enabled. Not adding rule for #{port}."
  else

    # Setup iptables rebuild resouce
    execute "rebuild-iptables" do
      command "/usr/sbin/rebuild-iptables"
      action :nothing
    end

    if machine_tag
      rs_utils_server_collection collection_name do
        tags machine_tag
        secondary_tags ip_tag
      end
    end

    ruby_block 'Register all currently active app servers' do
      block do
        ip_list = []

        # Add specific ip address
        ip_list << ip_addr if ip_addr

        # Add tagged servers
        if machine_tag
          valid_ip_regex = '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
          ip_list = node[:server_collection][collection_name].collect do |_, tags|
            RightScale::Utils::Helper.get_tag_value(ip_tag, tags, valid_ip_regex)
          end
        end # if tag

        # Use iptables cookbook to create open/close port for ip list
        ip_list.each do |ip|

          Chef::Log.info "Updating iptables rule for IP Address: #{ip}"

          rule = "port_#{port}"
          rule << "_#{ip.gsub('/','_')}_#{protocol}"

          # Programatically execute template resource
          RightScale::System::Helper.run_template(
                "/etc/iptables.d/#{rule}",    # target_file
                "iptables_port.erb",          # source
                "sys_firewall",               # cookbook
                {                             # variables
                  :port => port,
                  :protocol => protocol,
                  :ip_addr => (ip == "any") ? nil : ip
                },
                to_enable,                    # enable
                "/usr/sbin/rebuild-iptables", # command to run
                node,
                @run_context)
        end # each


      end # block
    end # ruby_block

  end # else

end # action

action :update_request do


  # Deal with attributes
  port = new_resource.port ? new_resource.port : new_resource.name
  to_enable = new_resource.enable
  ip_addr = new_resource.ip_addr
  raise "ERROR: client_ip must be specified." unless ip_addr
  machine_tag = new_resource.machine_tag
  raise "ERROR: machine_tag must be specified." unless machine_tag

  # Tell user what is going on
  msg = "Requesting port #{port} be #{to_enable ? "opened" : "closed"}"
  msg << " only for #{ip_addr}." if ip_addr
  msg << " on servers with tag: #{machine_tag}."
  log msg

  # Setup attributes
  attrs = {:sys_firewall => {:rule => Hash.new}}
  attrs[:sys_firewall][:rule][:port] = port
  attrs[:sys_firewall][:rule][:enable] = (to_enable == true) ? "enable" : "disable"
  attrs[:sys_firewall][:rule][:ip_address] = ip_addr

  # Use RightNet to update firewall rules on all tagged servers
  remote_recipe "Request firewall update" do
    recipe "sys_firewall::setup_rule"
    recipients_tags machine_tag
    attributes attrs
  end

end

