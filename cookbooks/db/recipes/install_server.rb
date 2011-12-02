#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Master DNS TTL Check - HA Only
#
# Checks the TTL of the Master DNS entry and exits with an error if the 
# TTL is greater than 120 seconds. The purpose of this script is to prevent 
# future DNS related problems pertaining to your database. For example, if you
# accidentally configure a DNS TTL of 3600 seconds on your Master DB DNS A 
# Record, it might work fine at first, but you will experience issues when you 
# attempt to promote a Slave-DB to Master-DB. As a best practice you should 
# use a low TTL for your database that's less than or equal to 120 seconds. 
#
log "Checking master database TTL settings..." do
  not_if { node[:db][:fqdn] == "localhost" }
end

log "Skipping master database TTL check for FQDN 'localhost'." do
  only_if { node[:db][:fqdn] == "localhost" }
end

ruby_block "Master DNS TTL Check" do
  not_if { node[:db][:fqdn] == "localhost" }
  block do
    MASTER_DB_DNSNAME = "#{node[:db][:fqdn]}"
    OPT_DNS_TTL_LIMIT = 120

    dnsttl=`dig #{MASTER_DB_DNSNAME} | grep ^#{MASTER_DB_DNSNAME} | awk '{ print $2}'`
    if dnsttl.to_i > OPT_DNS_TTL_LIMIT
       raise "Master DB DNS TTL set to high.  Must be set <= #{OPT_DNS_TTL_LIMIT}"
    end
    Chef::Log.info("Pass: Master DB DNS TTL: #{dnsttl}")
  end
end

# Add database tag
#
# Let others know we are an active DB
#
right_link_tag "database:active=true"

db node[:db][:data_dir] do
  user node[:db][:admin][:user]
  password node[:db][:admin][:password]
  action :install_server
end

rs_utils_marker :end
