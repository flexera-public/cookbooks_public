#
# Cookbook Name:: repo
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


actions :pull
actions :capistrano_pull


#Common attributes

#Path to where project repo will be pulled
attribute :destination, :kind_of => String

#Repository Url
attribute :repository, :kind_of => String

#Remote repo Branch or revision
attribute :revision, :kind_of => String


#Subversion only

#Subversion username
attribute :svn_username, :kind_of => String

#Subversion password
attribute :svn_password, :kind_of => String

#Extra arguments passed to the subversion command
attribute :svn_arguments, :kind_of => String

#Git only

#Ssh key
attribute :ssh_key, :kind_of => String

#Capistrano

#System user to run the deploy as
attribute :app_user, :kind_of => String

#An array of paths, relative to app root, to be removed from a checkout before symlinking
attribute :purge_before_symlink, :kind_of => Array, :default => %w{}

#Directories to create before symlinking. Runs after purge_before_symlink
attribute :create_dirs_before_symlink, :kind_of => Array, :default => %w{}

#A hash that maps files in the shared directory to their paths in the current release
attribute :symlinks, :kind_of => Hash, :default => ({})

#@group[Capistrano attributes] A hash of the form {"ENV_VARIABLE"=>"VALUE"}
attribute :environment, :kind_of => Hash, :default => ({})

#ROS

#The prefix that will be used to name/locate the backup of a particular code repo.
attribute :prefix, :kind_of => String

#Location where dump file will be saved. Used by dump recipes to back up to Amazon S3 or Rackspace Cloud Files.
attribute :storage_account_provider, :kind_of => String

#The cloud storage location where the dump file will be restored from.
#  For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.
attribute :container, :kind_of => String

#In order to read/write the container file to the specified cloud storage location, you need to provide cloud authentication credentials.
#  For Amazon S3, use your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID).
#  For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME).
attribute :storage_account_id, :kind_of => String

#In order to read/write the container file to the specified cloud storage location, you will need to provide cloud authentication credentials.
#  For Amazon S3, use your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY).
#  For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY).
attribute :storage_account_secret, :kind_of => String

#Unpack downloaded source or not Source file must be kind of tar archive
attribute :unpack_source, :equal_to => [ true, false ], :default => true
