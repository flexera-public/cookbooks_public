#
# Cookbook Name:: repo_ros
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


action :pull do

  # Check variables and log/skip if not set
  log "  Trying to get ros repo from: #{new_resource.storage_account_provider}, bucket: #{new_resource.container}"
  raise "  Repo container name not provided." unless new_resource.container
  raise "  Storage account provider ID not provided" unless new_resource.storage_account_id
  raise "  Storage account secret not provided" unless new_resource.storage_account_secret

  directory "#{new_resource.destination}/ros" do
    recursive true
  end

  #"true" we just put downloaded file into "destination" folder
  #"false" we put downloaded file into /tmp and unpack it into "destination" folder
  if (new_resource.unpack_source == true) then
    tmp_repo_path = "/tmp/downloaded_ros_archive.tar.gz"
  else
    tmp_repo_path = "#{new_resource.destination}/downloaded_ros_archive.tar.gz"
  end
  log("  Downloaded file will be available in #{tmp_repo_path}")

  cloud = ( new_resource.storage_account_provider == "CloudFiles" ) ? "rackspace" : "ec2"

  # Obtain the source from ROS
  execute "Download #{new_resource.container} from Remote Object Store" do
    command "/opt/rightscale/sandbox/bin/ros_util get --cloud #{cloud} --container #{new_resource.container} --dest #{tmp_repo_path} --source #{new_resource.prefix} --latest"
    environment ({
        'STORAGE_ACCOUNT_ID' => new_resource.storage_account_id,
        'STORAGE_ACCOUNT_SECRET' => new_resource.storage_account_secret
    })
  end


  bash "Unpack #{tmp_repo_path} to #{new_resource.destination}" do
    cwd "/tmp"
    code <<-EOH
       tar xzf #{tmp_repo_path} -C #{new_resource.destination}
    EOH
    only_if do (new_resource.unpack_source == true) end
  end

  Log "  ROS repo pull action - finished successfully!"
end


action :capistrano_pull do

  repo_dir="/home"

  log("  Recreating project directory for :pull action")
  #in case if it is capistrano symlink
  directory "#{new_resource.destination}" do
    recursive true
    action :delete
    only_if do (::File.symlink?("#{new_resource.destination}") == true) end
  end

  capistrano_dir="/home/capistrano_repo"
  ruby_block "Backup old repo" do
    block do
     t=Time.now.gmtime
     now=t.strftime("%Y%m%d%H%M%S")
     Chef::Log.info("  Check previous repo in case of action change")
     if (::File.exists?("#{new_resource.destination}") == true && ::File.symlink?("#{new_resource.destination}") == false)
       ::File.rename("#{new_resource.destination}", "#{new_resource.destination}_old_#{now}")
     elsif (::File.exists?("#{new_resource.destination}") == true && ::File.symlink?("#{new_resource.destination}") == false && ::File.exists?("#{capistrano_dir}") == true)
       ::File.rename("#{new_resource.destination}", "#{capistrano_dir}/releases/_initial_#{now}")
     end
    end
   end

  directory "#{new_resource.destination}/ros" do
      recursive true
  end

  log("  Pulling source from ROS")
  action_pull

   #moving dir with downloaded and unpacked ROS source to temp folder
   #to prepare source for capistrano actions
   bash "Moving #{new_resource.destination} to #{repo_dir}/ros_repo/" do
    cwd "#{repo_dir}"
    code <<-EOH
       mv #{new_resource.destination} #{repo_dir}/ros_repo/
    EOH
  end

  log("  Preparing to capistrano deploy action. Setting parameters for the process...")
  destination = new_resource.destination
  app_user = new_resource.app_user
  purge_before_symlink = new_resource.purge_before_symlink
  create_dirs_before_symlink = new_resource.create_dirs_before_symlink
  symlinks = new_resource.symlinks
  environment = new_resource.environment
  scm_provider = new_resource.provider

  log("  Preparing git transformation")
  directory "#{repo_dir}/ros_repo/.git" do
    recursive true
    action :delete
  end

  #initialisation of new git repo with initial commit
  bash "Git init in project folder" do
      cwd "#{repo_dir}/ros_repo"
      code <<-EOH
        git init
        git add .
        git commit -a -m "fake commit"
      EOH
  end

  log("  Deploying new local git project repo from #{repo_dir}/ros_repo/  to #{destination}. New owner #{app_user}")
  log "  Deploy provider #{scm_provider}"
  capistranize_repo "Source repo" do
    repository "#{repo_dir}/ros_repo/"
    destination destination
    app_user app_user
    purge_before_symlink purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks symlinks
    scm_provider scm_provider
    environment  environment
  end


  log("  Cleaning transformation temp files")
  directory "#{repo_dir}/ros_repo/" do
    recursive true
    action :delete
  end

  #cleaning tmp files
  directory "#{repo_dir}/capistrano_repo/current/.git/" do
    recursive true
    action :delete
   end

  Log "  Capistrano ROS deployment action - finished successfully!"
end
