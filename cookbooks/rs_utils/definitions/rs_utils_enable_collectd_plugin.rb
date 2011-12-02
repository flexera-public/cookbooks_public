#
# Cookbook Name:: rs_utils
# 
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :rs_utils_enable_collectd_plugin do
  if(params[:name])
    node[:rs_utils][:plugin_list_ary] << params[:name] unless node[:rs_utils][:plugin_list_ary].include?(params[:name])
  end
end
