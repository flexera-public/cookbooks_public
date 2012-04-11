#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Sets a database server to be a master in a replication db setup.
# The tasks include setting up DNS, setting tags, and setting node attributes.
# == Params
# none
# == Exceptions
# none

define :db_register_master do

  # == Set master DNS
  # Do this first so that DNS can propagate while the recipe runs
  #
  private_ip = node[:cloud][:private_ips][0]
  log "   Setting master database #{node[:db][:dns][:master][:fqdn]} to #{private_ip}"
  sys_dns "default" do
    id node[:db][:dns][:master][:id]
    address private_ip
    action :set_private
  end
  
  # == Set master tags
  # Tag the server with the master tags rs_dbrepl:master_active 
  # and rs_dbrepl:master_instance_uuid
  #
  active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}-#{node[:db][:backup][:lineage]}"
  log "Tagging server with #{active_tag}"
  right_link_tag active_tag

  unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
  log "Tagging server with #{unique_tag}"
  right_link_tag unique_tag
  
  # == Set master node variables
  #
  ruby_block "initialize master state" do
    block do
      node[:db][:current_master_uuid] = node[:rightscale][:instance_uuid]
      node[:db][:current_master_ip] = node[:cloud][:private_ips][0]
      node[:db][:this_is_master] = true
    end
  end
end
