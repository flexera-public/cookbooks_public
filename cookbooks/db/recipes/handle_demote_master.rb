#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# == Clear master tag
#
unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "  Clear tag #{unique_tag}"
right_link_tag unique_tag do
  action :remove
end

# == Set master node variables
#
master_ip = node[:remote_recipe][:new_master_ip]
master_uuid = node[:remote_recipe][:new_master_uuid]
log "  Setting up new master uuid:#{master_uuid} ip:#{master_ip}"
ruby_block "set slave state" do 
  block do 
    node[:db][:current_master_uuid] = master_uuid
    node[:db][:current_master_ip] = master_ip
    node[:db][:this_is_master] = false
  end
end

rs_utils_marker :end
