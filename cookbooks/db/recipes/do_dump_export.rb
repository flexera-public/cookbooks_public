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

dumpfilename = node[:db][:dump][:prefix] + "-" + Time.now.strftime("%Y%m%d%H%M") + ".gz"
dumpfilepath = "/tmp/#{dumpfilename}"

container   = node[:db][:dump][:container]
cloud       = ( node[:db][:dump][:storage_account_provider] == "CloudFiles" ) ? "rackspace" : "ec2"

# Execute the command to create the dumpfile
db node[:db][:data_dir] do
  dumpfile dumpfilepath
  action :generate_dump_file
end

# Upload the files to ROS
execute "Upload dumpfile to Remote Object Store" do
  command "/opt/rightscale/sandbox/bin/mc_sync.rb put --cloud #{cloud} --container #{container} --dest #{dumpfilename} --source #{dumpfilepath}"
  environment ({
    'STORAGE_ACCOUNT_ID' => node[:db][:dump][:storage_account_id],
    'STORAGE_ACCOUNT_SECRET' => node[:db][:dump][:storage_account_secret]
  })
end

# Delete the local file
file dumpfilepath do
  action :delete
end

rs_utils_marker :end
