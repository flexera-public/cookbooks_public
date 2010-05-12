
# Cookbook Name:: rs_utils
# Recipe:: install_file_stats_collectd_plugin
#
# Copyright (c) 2010 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'fileutils'

log "Installing file_stats collectd plugin.."

template(::File.join(node.rs_utils.collectd_plugin_dir, "file-stats.conf")) do
  source "file-stats.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

directory ::File.join(node.rs_utils.collectd_lib, "plugins") do
  action :create
  recursive true
end

remote_file(::File.join(node.rs_utils.collectd_lib, "plugins", 'file-stats.rb')) do
  source "file-stats.rb"
  mode "0755"
  notifies :restart, resources(:service => "collectd")
end

# Used in db_mysql::do_backup in cookbooks_premium for backups
file node.rs_utils.mysql_binary_backup_file do
  action :touch
  owner "nobody"
  group value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "nobody"}, "default" => "nogroup")
end

ruby_block "add_collectd_gauges" do
  block do
    types_file = ::File.join(node.rs_utils.collectd_lib, 'types.db')
    typesdb = IO.read(types_file)
    unless typesdb.include?('gague-age') && typesdb.include?('gague-size')
      typesdb += "\ngauge-age          seconds:GAUGE:0:200000000\ngauge-size          bytes:GAUGE:0:200000000\n"
      File.open(types_file, "w") { |f| f.write(typesdb) }
    end
  end
end

log "Installed collectd file_stats plugin."
