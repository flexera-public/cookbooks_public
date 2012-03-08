#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Run specific to application user defined commands
# for example  rake gem:install or rake db:create
#
# Variable node[:app_passenger][:opt_custom_cmd] contains comma separated list of commands along
# in the format:
#
#   command1, command2
#

log "  Running user defined commands"
bash "run commands" do
  flags "-ex"
  cwd "#{node[:app_passenger][:deploy_dir]}/"
  code <<-EOH
    IFS=,  read -a ARRAY1 <<< "#{node[:app_passenger][:project][:custom_cmd]}"
    for i in "${ARRAY1[@]}"
    do
      tmp=`echo $i | sed 's/^[ \t]*//'`
      /opt/ruby-enterprise/bin/$tmp
    done
  EOH
  only_if do (node[:app_passenger][:project][:custom_cmd]!="") end
end

rs_utils_marker :end
