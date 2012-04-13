#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


#memcached install
log "  Installing memcached package for #{node[:platform]}"

package "memcached" do
    not_if {File.exists?("#{node[:memcached][:config_file]}")}
end

log "  Installation complete."


service "memcached" do
    action :nothing
    persist true
    supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end


#memcached config
log "  Cache size will be set to #{node[:memcached][:memtotal_percent]}% of total system memory #{node[:memory][:total]} : #{node[:memcached][:memtotal]}kB"

template "#{node[:memcached][:config_file]}" do
    source "memcached.conf.erb"
    variables(
            :port             => node[:memcached][:port],
            :user             => node[:memcached][:user],
            :connection_limit => node[:memcached][:connection_limit],
            :memtotal         => node[:memcached][:memtotal],
            :extra_options    => node[:memcached][:extra_options]
    )
    cookbook 'memcached'
    notifies :restart, resources(:service => "memcached"), :immediately
end

log "  Configuration done."
log "  Memcached server started."


rs_utils_marker :end