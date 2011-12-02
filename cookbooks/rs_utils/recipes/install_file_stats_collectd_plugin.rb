#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Load the exec plugin in the main config file
rs_utils_enable_collectd_plugin "exec"
#node[:rs_utils][:plugin_list] += " exec" unless node[:rs_utils][:plugin_list] =~ /exec/

include_recipe "rs_utils::setup_monitoring"

require 'fileutils'

log "Installing file_stats collectd plugin.."

template(::File.join(node[:rs_utils][:collectd_plugin_dir], "file-stats.conf")) do
  backup false
  source "file-stats.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

directory ::File.join(node[:rs_utils][:collectd_lib], "plugins") do
  action :create
  recursive true
end

remote_file(::File.join(node[:rs_utils][:collectd_lib], "plugins", 'file-stats.rb')) do
  source "file-stats.rb"
  mode "0755"
  notifies :restart, resources(:service => "collectd")
end

# Used in db_mysql::do_backup in cookbooks_premium for backups
file node[:rs_utils][:db_backup_file] do
  action :touch
  owner "nobody"
  group value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "nobody"}, "default" => "nogroup")
end

ruby_block "add_collectd_gauges" do
  block do
    types_file = ::File.join(node[:rs_utils][:collectd_share], 'types.db')
    typesdb = IO.read(types_file)
    unless typesdb.include?('gague-age') && typesdb.include?('gague-size')
      typesdb += "\ngauge-age          seconds:GAUGE:0:200000000\ngauge-size          bytes:GAUGE:0:200000000\n"
      File.open(types_file, "w") { |f| f.write(typesdb) }
    end
  end
end

log "Installed collectd file_stats plugin."

rs_utils_marker :end
