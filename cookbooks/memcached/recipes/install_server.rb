#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


###memcached install
log "  Installing memcached package for #{node[:platform]}"

package "memcached" do
    not_if {File.exists?("#{node[:memcached][:config_file]}")}
end

log "  Installation complete."

service "memcached" do
    action :nothing
    persist true
    reload_command "/etc/init.d/memcached force-reload"
    supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end


###memcached config
log "  Cache size will be set to #{node[:memcached][:memtotal_percent]}% of total system memory #{node[:memory][:total]} : #{node[:memcached][:memtotal]}kB"

#thread number check
if node[:memcached][:threads].to_i < 1
    log "  Number of threads less than 1, using minimum possible"
    node[:memcached][:threads] = "1"
elsif node[:memcached][:threads].to_i  > node[:cpu][:total].to_i
    log "  Number of threads more than #{node[:cpu][:total]}, using maximum available"
    node[:memcached][:threads] = node[:cpu][:total]
end

#listening ip configuration
case node[:memcached][:ip]
    when "localhost"
        node[:memcached][:ip] = "localhost"
    when "private"
        node[:memcached][:ip] = node[:cloud][:private_ips][0]
    when "public"
        node[:memcached][:ip] = node[:cloud][:public_ips][0]
    when "any"
        node[:memcached][:ip] = "0"
end

#writing settings
template "#{node[:memcached][:config_file]}" do
    source "memcached.conf.erb"
    variables(
            :tcp_port         => node[:memcached][:tcp_port],
            :udp_port         => node[:memcached][:udp_port],
            :user             => node[:memcached][:user],
            :connection_limit => node[:memcached][:connection_limit],
            :memtotal         => node[:memcached][:memtotal],
            :threads          => node[:memcached][:threads],
            :ip               => node[:memcached][:ip],
            :log_level        => node[:memcached][:log_level]
    )
    cookbook 'memcached'
    notifies :restart, resources(:service => "memcached"), :immediately
end

log "  Configuration done."
log "  Memcached server started."

##collectd plugin
service "collectd" do
    action :stop
end

template "#{node[:rs_utils][:collectd_plugin_dir]}/memcached.conf" do
    source "memcached_collectd.conf.erb"
    variables(
            :ip              => node[:memcached][:ip],
            :tcp_port        => node[:memcached][:tcp_port]
    )
    cookbook 'memcached'
   notifies :start, resources(:service => "collectd"), :immediately
end
rs_utils_marker :end

log "  Collectd plugin configured"