#
# Cookbook Name:: repo
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Setup all resources that have attributes in the node"
node[:repo].each do |resource_name, entry|

  url = (entry[:repository]) ? entry[:repository] : ""
  branch = (entry[:revision]) ? entry[:revision] : ""
  svn_username = (entry[:svn_username]) ? entry[:svn_username] : ""
  svn_password = (entry[:svn_password]) ? entry[:svn_password] : ""
  key = (entry[:ssh_key]) ? entry[:ssh_key] : ""
  storage_account_provider = (entry[:storage_account_provider]) ? entry[:storage_account_provider] : ""
  storage_account_id = (entry[:storage_account_id]) ? entry[:storage_account_id] : ""
  storage_account_secret = (entry[:storage_account_secret]) ? entry[:storage_account_secret] : ""
  container = (entry[:container]) ? entry[:container] : ""
  prefix = (entry[:prefix]) ? entry[:prefix] : ""

  #Checking required user attributes
  case entry[:provider]
    when "repo_git"
      raise "  Error: repo URL input is unset. Please fill 'Repository Url' input" unless url != ""
      if entry[:revision]== ""
        log "  Warning: branch/tag input is empty, switching to 'master' branch"
        branch = "master"
       else
        branch = entry[:revision]
      end

    when "repo_ros"
      raise "  Error: ROS gem missing, please add rs_utils::install_tools or rs_tools::default recipes to runlist." unless File.exists?("/opt/rightscale/sandbox/bin/ros_util")

    when "repo_svn"
      raise "  Error: repo URL input is unset. Please fill 'Repository Url' input" unless url != ""
      if entry[:revision]== ""
        log "  Warning: branch/tag input is empty, switching to 'HEAD' version"
        branch = "HEAD"
       else
        branch = entry[:revision]
      end

  end

  log "  Registering #{resource_name} provider: #{entry[:provider]}"
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

