#
# Cookbook Name:: db_mysql
# Recipe:: do_tag_as_master
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}"
log "Tagging server with #{active_tag}"
right_link_tag active_tag

unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "Tagging server with #{unique_tag}"
right_link_tag unique_tag

log "Waiting for tags to exist..."
rs_utils_server_collection "master_servers" do
  tags [active_tag, unique_tag]
  empty_ok false
end

include_recipe "db_mysql::setup_master_dns"

rs_utils_marker :end
