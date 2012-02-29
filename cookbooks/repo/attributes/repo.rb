#
# Cookbook Name:: repo
# Attributes:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:repo][:default][:destination] = "/tmp/repo"
set_unless[:repo][:default][:repository] = ""
set_unless[:repo][:default][:revision] = "HEAD"
set_unless[:repo][:default][:provider] = "repo_git"
set_unless[:repo][:default][:svn_username] = ""
set_unless[:repo][:default][:svn_password] = ""
set_unless[:repo][:default][:ssh_key] = ""
set_unless[:repo][:default][:storage_account_provider] = "S3"
set_unless[:repo][:default][:storage_account_id] = ""
set_unless[:repo][:default][:storage_account_secret] = ""
set_unless[:repo][:default][:container] = ""
set_unless[:repo][:default][:prefix] = ""
set_unless[:repo][:default][:environment]= ({})
set_unless[:repo][:default][:symlinks]= ({})
set_unless[:repo][:default][:purge_before_symlink] = %w{}
set_unless[:repo][:default][:create_dirs_before_symlink] = %w{}

if set_unless[:repo][:default][:perform_action] == "pull"
  set_unless[:repo][:default][:perform_action] = :pull
else
  set_unless[:repo][:default][:perform_action] = :capistrano_pull
end
