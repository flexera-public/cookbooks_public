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

  # == Set master node variables
  # 
  # NOTE: this runs in the compile phase since it is needed for backup
  # schedule calculations.
  #
  node[:db][:current_master_uuid] = node[:rightscale][:instance_uuid]
  node[:db][:current_master_ip] = node[:cloud][:private_ips][0]
  node[:db][:this_is_master] = true

  # == Set master DNS
  # Do this first so that DNS can propagate while the recipe runs
  #
  include_recipe "sys_dns::do_set_private"

  # == Set master tags
  # Tag the server with the master tags rs_dbrepl:master_active 
  # and rs_dbrepl:master_instance_uuid
  #
  active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}"
  log "Tagging server with #{active_tag}"
  right_link_tag active_tag
  
  unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
  log "Tagging server with #{unique_tag}"
  right_link_tag unique_tag
end
