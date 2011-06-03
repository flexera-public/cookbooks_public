# Author: Ryan J. Geyer (<me@ryangeyer.com>)
# License: TBD

define :rs_utils_enable_collectd_plugin do
  if(params[:name])
    node[:rs_utils][:plugin_list_ary] << params[:name] unless node[:rs_utils][:plugin_list_ary].include?(params[:name])
  end
end