#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

skip, reason = true, "DB/Schema name not provided"           if node[:db][:dump][:database_name] == ""
skip, reason = true, "Prefix not provided"                   if node[:db][:dump][:prefix] == ""
skip, reason = true, "Storage account provider not provided" if node[:db][:dump][:storage_account_provider] == ""
skip, reason = true, "Storage Account ID not provided"       if node[:db][:dump][:storage_account_id] == ""
skip, reason = true, "Storage Account password not provided" if node[:db][:dump][:storage_account_secret] == ""
skip, reason = true, "Container not provided"                if node[:db][:dump][:container] == ""

if skip
  log "Skipping import: #{reason}"
else
  cron "db_dump_export" do
    hour "0"
    minute "#{5+rand(50)}"
    command "rs_run_recipe -n db::do_dump_export"
  end
end

rs_utils_marker :end

