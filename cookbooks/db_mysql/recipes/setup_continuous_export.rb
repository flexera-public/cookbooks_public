#
# Cookbook Name:: db_mysql
# Definition:: setup_continuous_export
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

temp_dir = node[:db_mysql][:tmpdir]
prefix = node[:db_mysql][:dump][:prefix]
dumpfile = "#{temp_dir}/#{prefix}.gz"

# == Add cron task for export
#
# Runs at a random minute after midnite to avoid traffic spikes.
#
cron "rightscale_mysql_dump_export" do
  hour "0"
  minute "#{5+rand(50)}"
  command "rs_run_recipe -n db_mysql::do_dump_export"
  only_if do ::File.exist?(dumpfile) end
end

