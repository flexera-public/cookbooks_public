#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

dumpfilename = node[:db][:dump][:prefix] + "-" + Time.now.strftime("%Y%m%d%H%M") + ".gz"
dumpfilepath = "/tmp/#{dumpfilename}"

databasename = node[:db][:dump][:database_name]

container   = node[:db][:dump][:container]
cloud       = node[:db][:dump][:storage_account_provider]

# Execute the command to create the dumpfile
db node[:db][:data_dir] do
  dumpfile dumpfilepath
  db_name databasename
  action :generate_dump_file
end

# Upload the files to ROS
execute "Upload dumpfile to Remote Object Store" do
  command "/opt/rightscale/sandbox/bin/ros_util put --cloud #{cloud} --container #{container} --dest #{dumpfilename} --source #{dumpfilepath}"
  environment ({
    'STORAGE_ACCOUNT_ID' => node[:db][:dump][:storage_account_id],
    'STORAGE_ACCOUNT_SECRET' => node[:db][:dump][:storage_account_secret]
  })
end

# Delete the local file
file dumpfilepath do
  backup false
  action :delete
end

rs_utils_marker :end
