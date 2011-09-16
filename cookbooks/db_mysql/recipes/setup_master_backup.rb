#
# Cookbook Name:: db_mysql
# Recipe:: setup_master_backup
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

log "Disabling slave continuous backup cron job (if exists):"
cron "Slave continuous backups" do
  user "root"
  action :delete
end

log "Enabling master continuous backup cron job: HOUR #{node[:db_mysql][:backup][:master][:hour]} MINUTE #{node[:db_mysql][:backup][:master][:minute]}"
cron "Master continuous backups" do
  minute  "#{node[:db_mysql][:backup][:master][:minute]}"
  hour    "#{node[:db_mysql][:backup][:master][:hour]}"
  user    "root"
  command "rs_run_recipe -n \"db_mysql::do_backup\" 2>&1 > /var/log/mysql_cron_backup.log"
  action :create
end

log "Enabling master continuous backup cron job:#{node[:db_mysql][:backup][:minute]} #{node[:db_mysql][:backup][:master][:hour]}"
cron "Master continuous backups" do
  minute "#{node[:db_mysql][:backup][:master][:minute]}"
  hour "#{node[:db_mysql][:backup][:master][:hour]}"
  user "root"
  command "rs_run_recipe -n \"db_mysql::do_backup\" 2>&1 > /var/log/mysql_cron_backup.log"
  action :create
end

rs_utils_marker :end
