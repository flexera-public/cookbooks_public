#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#
# RightScale Enviroment Attributes.
# These are needed by all RightScale Cookbooks.  rs_utils should be included in all server templates
# so these attributes are declared here.

#
# Optional attributes
#
set_unless[:rs_utils][:timezone] = "UTC"    
set_unless[:rs_utils][:process_list] = ""
set_unless[:rs_utils][:process_match_list] = ""   
set_unless[:rs_utils][:private_ssh_key] = ""
set_unless[:rs_utils][:collectd_share] = "/usr/share/collectd"

set_unless[:rs_utils][:db_backup_file] = "/var/run/db-backup"

default[:rs_utils][:plugin_list] = ""
default[:rs_utils][:plugin_list_ary] = [
  "cpu",
  "df",
  "disk",
  "load",
  "memory",
  "processes",
  "swap",
  "users",
  "ping"
]

default[:rs_utils][:process_list] = ""
default[:rs_utils][:process_list_ary] = []

#
# Setup Distro dependent variables
#
case platform
when "redhat","centos","fedora","suse"
  rs_utils[:logrotate_config] = "/etc/logrotate.d/syslog"
  rs_utils[:collectd_config] = "/etc/collectd.conf"
  rs_utils[:collectd_plugin_dir] = "/etc/collectd.d"
when "debian","ubuntu"
  rs_utils[:logrotate_config] = "/etc/logrotate.d/syslog-ng"
  rs_utils[:collectd_config] = "/etc/collectd/collectd.conf"
  rs_utils[:collectd_plugin_dir] = "/etc/collectd/conf"
end

rs_utils[:collectd_lib] = "/usr/lib64/collectd"

default[:rs_utils][:short_hostname]        = nil
default[:rs_utils][:domain_name]           = ""
default[:rs_utils][:search_suffix]         = ""

#
# Cloud specific attributes
#
rs_utils[:enable_remote_logging] = false
if cloud
  case cloud[:provider]
  when "ec2"
    rs_utils[:enable_remote_logging] = true
  end
end

