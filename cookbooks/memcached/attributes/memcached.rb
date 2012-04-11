#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:memcached][:port] = 11211
set_unless[:memcached][:memtotal_percent] = 90

set_unless[:memcached][:ip] = ""

set_unless[:memcached][:user] = "nobody"
set_unless[:memcached][:user] = "nobody"

set_unless[:memcached][:connection_limit] = 1024

set_unless[:memcached][:threads] = "nobody"

set_unless[:memcached][:log_level] = "" # off, -v (verbose) -vv (debug) -vvv (extremely verbose)


set[:memcached][:ubuntu][:config_file] = "/etc/memcached.conf"
set[:memcached][:centos][:config_file] = "/etc/sysconfig/memcached"

set[:memcached][:ubuntu][:iptables_rules] = "/etc/iptables.rules"
set[:memcached][:centos][:iptables_rules] = "/etc/sysconfig/iptables"


# Calculated options
#set_unless[:memcached][:threads] = node[:cpu].count