#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

block_device DATA_DIR do
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  action :backup_schedule_disable
end

rs_utils_marker :end
