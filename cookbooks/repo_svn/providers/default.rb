#
# Cookbook Name:: repo_svn
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :pull do

  # setup parameters 
  password = new_resource.svn_password
  branch = new_resource.revision
  params = "--no-auth-cache --non-interactive"
  params << " --username #{new_resource.svn_username} --password #{password}" if "#{password}" != ""
  params << " --revision #{branch}" if "#{branch}" != ""

  # pull repo (if exist)
  ruby_block "Pull existing Subversion repository at #{new_resource.destination}" do
    only_if do ::File.directory?(new_resource.destination) end
    block do
      Dir.chdir new_resource.destination
      Chef::Log.info "Updating existing svn repo at #{new_resource.destination}"
      Chef::Log.info `svn update #{params} #{new_resource.repository} #{new_resource.destination}` 
    end
  end

  # clone repo (if not exist)
  ruby_block "Checkout new Subversion repository to #{new_resource.destination}" do
    not_if do ::File.directory?(new_resource.destination) end
    block do
      Chef::Log.info "block executed"
      Chef::Log.info "Creating new svn repo at #{new_resource.destination} #{params} #{new_resource.repository}"
      Chef::Log.info `svn checkout #{params} #{new_resource.repository} #{new_resource.destination}`
    end
  end

  Log "  ROS repo pull action - finished successfully!"
end

action :capistrano_pull do

  log("  Preparing to capistrano deploy action. Setting parameters for the process...")
  destination = new_resource.destination
  repository = new_resource.repository
  revision = new_resource.revision
  svn_username = new_resource.svn_username
  svn_password = new_resource.svn_password
  app_user = new_resource.app_user
  purge_before_symlink = new_resource.purge_before_symlink
  create_dirs_before_symlink = new_resource.create_dirs_before_symlink
  symlinks = new_resource.symlinks
  scm_provider = new_resource.provider
  environment = new_resource.environment

  log("  Deploying branch: #{revision} of the #{repository} to #{destination}. New owner #{app_user}")
  log "  Deploy provider #{scm_provider}"

  capistranize_repo "Source repo" do
    repository repository
    destination destination
    revision revision
    svn_username svn_username
    svn_password svn_password
    app_user app_user
    purge_before_symlink purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlink_before_migrate symlink_before_migrate
    symlinks symlinks
    environment environment
    scm_provider scm_provider
  end

  Log "  Capistrano SVN deployment action - finished successfully!"
end
