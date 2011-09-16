#
# Cookbook Name:: db_mysql
# Recipe:: setup_slave_backup
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

log "Disabling master continuous backup cron job (if exists)"
cron "Master continuous backups" do
  user "root"
  action :delete
end

log "Enabling slave continuous backup cron job: hour: #{node[:db_mysql][:backup][:slave][:hour]} minute: #{node[:db_mysql][:backup][:slave][:minute]}"
cron "Slave continuous backups" do
  minute "#{node[:db_mysql][:backup][:slave][:minute]}"
  hour "#{node[:db_mysql][:backup][:slave][:hour]}"
  user "root"
  command "rs_run_recipe -n \"db::do_backup\" 2>&1 > /var/log/mysql_cron_backup.log"
  action :create
end

rs_utils_marker :end
