# Cookbook Name:: db
# 
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

rs_utils_marker :begin

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
  cloud        = ( node[:db][:dump][:storage_account_provider] == "CloudFiles" ) ? "rackspace" : "ec2"

  # Obtain the dumpfile from ROS 
  execute "Download dumpfile from Remote Object Store" do
    command "/opt/rightscale/sandbox/bin/mc_sync.rb get --cloud #{cloud} --container #{container} --dest #{dumpfilepath} --source #{prefix} --latest"
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
