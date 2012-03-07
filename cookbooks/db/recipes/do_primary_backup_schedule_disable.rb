#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

NICKNAME = get_device_or_default(node, :device1, :nickname)

block_device NICKNAME do
  cron_backup_recipe "#{self.cookbook_name}::do_primary_backup"
  action :backup_schedule_disable
end

rs_utils_marker :end
