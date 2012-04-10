#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Check for valid prefix / dump filename
dump_file_regex = '(^\w+)(-\d{1,12})*$'
raise "Prefix: #{node[:db][:dump][:prefix]} invalid.  It is restricted to word characters (letter, number, underscore) and an optional partial timestamp -YYYYMMDDHHMM.  (=~/#{dump_file_regex}/ is the ruby regex used). ex: myapp_prod_dump, myapp_prod_dump-201203080035 or myapp_prod_dump-201203" unless node[:db][:dump][:prefix] =~ /#{dump_file_regex}/ || node[:db][:dump][:prefix] == ""

# Check variables and log/skip if not set
skip, reason = true, "DB/Schema name not provided"           if node[:db][:dump][:database_name] == ""
skip, reason = true, "Prefix not provided"                   if node[:db][:dump][:prefix] == ""
skip, reason = true, "Storage account provider not provided" if node[:db][:dump][:storage_account_provider] == ""
skip, reason = true, "Container not provided"                if node[:db][:dump][:container] == ""

if skip
  log "Skipping import: #{reason}"
else

  db_name      = node[:db][:dump][:database_name]
  prefix       = node[:db][:dump][:prefix]
  dumpfilepath = "/tmp/" + prefix + ".gz"
  container    = node[:db][:dump][:container]
  cloud        = node[:db][:dump][:storage_account_provider]

  # Obtain the dumpfile from ROS 
  execute "Download dumpfile from Remote Object Store" do
    command "/opt/rightscale/sandbox/bin/ros_util get --cloud #{cloud} --container #{container} --dest #{dumpfilepath} --source #{prefix} --latest"
    creates dumpfilepath
    environment ({
      'STORAGE_ACCOUNT_ID' => node[:db][:dump][:storage_account_id],
      'STORAGE_ACCOUNT_SECRET' => node[:db][:dump][:storage_account_secret]
    })
  end

  # Restore the dump file to db. 
  db node[:db][:data_dir] do
    dumpfile dumpfilepath
    db_name db_name
    action :restore_from_dump_file
  end

  # Delete the local file.
  file dumpfilepath do
    backup false
    action :delete
  end

end

rs_utils_marker :end
