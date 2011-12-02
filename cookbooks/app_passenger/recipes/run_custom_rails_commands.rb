# Cookbook Name:: app_passenger
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

# Run specific to application user defined commands
# for example  rake gem:install or rake db:create
#
# Variable node[:app_passenger][:opt_custom_cmd] contains comma separated list of commands along
# in the format:
#
#   command1, command2
#

  log "Running user defined commands"
bash "run commands" do
  cwd "#{node[:app_passenger][:deploy_dir]}/current/"
  code <<-EOH
    IFS=,  read -a ARRAY1 <<< "#{node[:app_passenger][:opt_custom_cmd]}"
    for i in "${ARRAY1[@]}"
    do
      tmp=`echo $i | sed 's/^[ \t]*//'`
      /opt/ruby-enterprise/bin/$tmp
    done
  EOH
  only_if do (node[:app_passenger][:opt_custom_cmd]!="") end
end

rs_utils_marker :end
