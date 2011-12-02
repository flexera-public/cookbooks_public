#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == remove cron task for export
#
rs_utils_marker :begin

cron "db_dump_export" do
  action :delete
end

rs_utils_marker :end
