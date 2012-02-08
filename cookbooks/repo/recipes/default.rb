#
# Cookbook Name:: repo
# Recipe:: default
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

#nessesary fo repo_ros provider
include_recipe "rs_tools::default"

  log "  Setup all resources that have attributes in the node"
node[:repo].each do |resource_name, entry|

  url = (entry[:repository]) ? entry[:repository] : ""
  svn_username = (entry[:svn_username]) ? entry[:svn_username] : ""
  svn_password = (entry[:svn_password]) ? entry[:svn_password] : ""
  key = (entry[:ssh_key]) ? entry[:ssh_key] : ""
  storage_account_provider = (entry[:storage_account_provider]) ? entry[:storage_account_provider] : ""
  storage_account_id = (entry[:storage_account_id]) ? entry[:storage_account_id] : ""
  storage_account_secret = (entry[:storage_account_secret]) ? entry[:storage_account_secret] : ""
  container = (entry[:container]) ? entry[:container] : ""
  prefix = (entry[:prefix]) ? entry[:prefix] : ""

  case entry[:provider]
    when "repo_git"
      branch = (entry[:revision]) ? entry[:revision] : "master"
    else
      branch = (entry[:revision]) ? entry[:revision] : "HEAD"
  end

  log "  Registering #{resource_name} prov: #{entry[:provider]}"
  repo resource_name do
      provider entry[:provider]
      repository url
      revision branch
      ssh_key key
      svn_username svn_username
      svn_password svn_password
      storage_account_provider storage_account_provider
      storage_account_id storage_account_id
      storage_account_secret storage_account_secret
      container container
      unpack_source true
      prefix prefix
      persist true
  end
end



rs_utils_marker :end


