#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

capistrano_dir="/home/capistrano_repo"
define :capistranize_repo,
       :destination => "",
       :repository => "",
       :revision => "",
       :svn_username => "",
       :svn_password => "",
       :app_user => "",
       :environment => ({}),
       :create_dirs_before_symlink => %w{},
       :purge_before_symlink => %w{},
       :symlinks => ({}),
       :scm_provider=> "" do

  Log "  Capistrano deployment creation - in progress..."

  ruby_block "Before deploy" do
    block do
     Chef::Log.info("check previous repo in case of action change")
      if (::File.exists?("#{params[:destination]}") == true && ::File.symlink?("#{params[:destination]}") == false)
        ::File.rename("#{params[:destination]}", "#{params[:destination]}_old")
      elsif (::File.exists?("#{params[:destination]}") == true && ::File.symlink?("#{params[:destination]}") == true && ::File.exists?("#{capistrano_dir}") == false)
        ::File.rename("#{params[:destination]}", "#{params[:destination]}_old")
      end
    end
  end


  directory "#{capistrano_dir}/shared/" do
    recursive true
  end

  directory "#{capistrano_dir}/shared/cached-copy" do
    recursive true
    action :delete
  end


  if params[:scm_provider] == Chef::Provider::RepoSvn
    scm_prov = Chef::Provider::Subversion
    svn_args = "--no-auth-cache --non-interactive"
    enable_submodules = false

  else
    scm_prov = Chef::Provider::Git
    svn_args = nil
    params[:svn_username] = nil
    params[:svn_password] = nil
    enable_submodules = true

  end
  Log "  Capistrano deployment will use #{scm_prov} for initialization"

  deploy "#{capistrano_dir}" do
    scm_provider               scm_prov
    repo                       "#{params[:repository].chomp}"
    revision                   params[:revision]
    svn_username               params[:svn_username]
    svn_password               params[:svn_password]
    svn_arguments              svn_args
    enable_submodules          enable_submodules
    shallow_clone              false
    user                       params[:app_user]
    migrate                    false
    purge_before_symlink       params[:purge_before_symlink]
    create_dirs_before_symlink params[:create_dirs_before_symlink]
    symlink_before_migrate     ({})
    symlinks                   params[:symlinks] #({})
    action                     :deploy
    environment                params[:environment]
  end

  Log "  Capistrano deployment created.  Performing secondary operations"
  link params[:destination] do
    action :delete
    only_if "test -L #{params[:destination].chomp}"
  end


  ruby_block "After deploy" do
    block do
      Chef::Log.info("  Perform backup of old deployment directory to #{capistrano_dir}/releases/ ")
      system("data=`/bin/date +%Y%m%d%H%M%S` && mv #{params[:destination]}_old #{capistrano_dir}/releases/${data}_initial")

      repo_dest = params[:destination]
      #checking last symbol of "destination" for correct work of "cp -d"
      if (params[:destination].end_with?("/"))
        repo_dest = params[:destination].chop
      end


      Chef::Log.info("  linking #{capistrano_dir}/current/ directory to project root -  #{repo_dest}")
     system("cp -d #{capistrano_dir}/current #{repo_dest}")
    end

  end

end
