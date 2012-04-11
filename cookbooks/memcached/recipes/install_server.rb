#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "node[:memory][:total]: #{node[:memory][:total]} #{node[:memory][:total].class}"
log "node[:memcached][:memtotal_percent]: #{node[:memcached][:memtotal_percent]} #{node[:memcached][:memtotal_percent].class}"
node[:memcached][:memtotal] = node[:memory][:total].to_i * ( node[:memcached][:memtotal_percent] / 100.0 )
log "[:memcached][:memtotal]: #{node[:memcached][:memtotal]}"

#memcached install
log "  Installing memcached package for #{node[:platform]}"
package "memcached" do
  not_if {File.exists?("#{node[:memcached][:config_file]}")}
end
log "  Installation complete!"


#memcached config
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
end
log "  Configuration done!"

rs_utils_marker :end