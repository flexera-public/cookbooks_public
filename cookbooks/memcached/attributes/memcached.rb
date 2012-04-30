#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
set_unless[:memcached][:tcp_port]         = "11211"
set_unless[:memcached][:udp_port]         = "11211"
set_unless[:memcached][:user]             = "nobody"
set_unless[:memcached][:connection_limit] = "1024"
set_unless[:memcached][:memtotal_percent] = "90"
set_unless[:memcached][:threads]          = "1"
set_unless[:memcached][:ip]               = "any"
set_unless[:memcached][:log_level]        = ""
set_unless[:memcached][:cluster_id]       = ""


# Calculated attributes
node[:memcached][:memtotal] = (((node[:memcached][:memtotal_percent].to_i/100.0)*node[:memory][:total].to_i)/1024.0).to_i

case node[:platform]

    when "ubuntu", "debian"
        set[:memcached][:config_file]    = "/etc/memcached.conf"
        set[:memcached][:iptables_rules] = "/etc/iptables.rules"

    when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
        set[:memcached][:config_file]    = "/etc/sysconfig/memcached"
        set[:memcached][:iptables_rules] = "/etc/sysconfig/iptables"

    else
        raise "Unrecognized platform #{node[:platform]}, exiting "

end

