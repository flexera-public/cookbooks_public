#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Run only on master server
if node[:rightscale][:instance_uuid] == "#{node[:db][:current_master_uuid]}"
#
# Show sync mode status
#
    bash "show sync mode status" do
      user "postgres"
      code <<-EOH
        echo "==================== do_show_slave_mode : Begin =================="

        psql -h #{node[:db_postgres][:socket]} -U postgres -c "select application_name, client_addr, sync_state from pg_stat_replication"

        echo "==================== do_show_slave_mode : End ===================="
      EOH
    end

else
  raise "This is not master server! This script only runs on master: #{node[:db][:current_master_uuid]}"
end

rs_utils_marker :end
