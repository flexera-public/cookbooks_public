#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# == Set Slave DNS Record
#
# Sets the Slave DNS record to the private ip of the server.
#
# Raise exception if this server thinks it is a master.

raise "ERROR: Server is a master" if node[:db][:this_is_master]
log 'WARN: Slave database is not initialized!' do
  only_if { node[:db][:init_status] == :uninitialized }
  level :warn
end

private_ip = node[:cloud][:private_ips][0]
log "   Setting slave #{node[:db][:dns][:slave][:fqdn]} to #{private_ip}"
sys_dns "default" do
  id node[:db][:dns][:slave][:id]
  address private_ip
  action :set_private
end

rs_utils_marker :end
