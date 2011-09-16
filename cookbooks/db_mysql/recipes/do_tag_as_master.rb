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
COLLECTION_NAME = "master_servers"
wait_for_tag active_tag do
  collection_name COLLECTION_NAME
end

wait_for_tag unique_tag do
  collection_name COLLECTION_NAME
end

include_recipe "db_mysql::setup_master_dns"

rs_utils_marker :end
