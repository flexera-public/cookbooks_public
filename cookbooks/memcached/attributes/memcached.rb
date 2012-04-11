#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
set_unless[:memcached][:port] = 11211
set_unless[:memcached][:memtotal_percent] = 90
set_unless[:memcached][:ip] = ""
set_unless[:memcached][:extra_options] = ""
set_unless[:memcached][:user] = "nobody"
set_unless[:memcached][:connection_limit] = 1024
set_unless[:memcached][:log_level] = "" # off, -v (verbose) -vv (debug) -vvv (extremely verbose)
set_unless[:memcached][:threads] = node[:cpu].count


# Calculated attributes
#node[:memcached][:memtotal] = node[:memory][:total].to_i * ( node[:memcached][:memtotal_percent] / 100.0 )
#log "Memcache total memory: #{node[:memcached][:memtotal]}"

case node[:platform]

  when "ubuntu", "debian"
    set[:memcached][:config_file] = "/etc/memcached.conf"
    set[:memcached][:iptables_rules] = "/etc/iptables.rules"

  when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
    set[:memcached][:config_file] = "/etc/sysconfig/memcached"
    set[:memcached][:iptables_rules] = "/etc/sysconfig/iptables"

  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end




