# Author: Ryan J. Geyer (<me@ryangeyer.com>)
# License: TBD

define :rs_utils_monitor_process do
  if(params[:name])
    node[:rs_utils][:process_list_ary] << params[:name] unless node[:rs_utils][:process_list_ary].include?(params[:name])
  end
end