maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Abstract cookbook for managing source code repositories."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))

version          "0.0.1"

depends "rs_utils"
depends "repo_svn"
depends "repo_git"
depends "repo_ros"

recipe  "repo::default", "Default recipe for setup resources provided"
recipe  "repo::do_pull", "Recipe for pulling project repos from svn, git or ros."

attribute "repo/default/provider",
  :display_name => "Repository Provider",
  :description => "Select a repository provider: repo_git for Git, repo_svn for SVN or repo_ros for Remote Ojbect Store. Default: repo_git",
  :required => "recommended",
  :choice => ["repo_git", "repo_svn", "repo_ros"],
  :default => "repo_git",
  :recipes => ["repo::default"]

attribute "repo/default/repository",
  :display_name => "Repository Url",
  :description => "The URL of your svn or git repository where your application code will be checked out. Ex: http://mysvn.net/app/ or git@github.com/whoami/project",
  :required => "recommended",
  :recipes => ["repo::default"]

attribute "repo/default/revision",
  :display_name => "Branch/Tag",
  :description => "Enter the branch of your repository you want to fetch. Default: master",
  :required => "recommended",
  :default => "master",
  :recipes => ["repo::default"]

#SVN
attribute "repo/default/svn_username",
  :display_name => "SVN username",
  :description => "Username for SVN repository.",
  :required => "optional",
  :default => "",
  :recipes => ["repo::default"]

attribute "repo/default/svn_password",
  :display_name => "SVN password",
  :description => "Password for SVN repository.",
  :required => "optional",
  :default => "",
  :recipes => ["repo::default"]

#GIT
attribute "repo/default/ssh_key",
  :display_name => "SSH Key",
  :description => "The private SSH key of the git repository.",
  :default => "",
  :required => "recommended",
  :recipes => ["repo::default"]

#ROS
attribute "repo/default/storage_account_provider",
  :display_name => "ROS Storage Account Provider",
  :description => "Location where the source file is saved. Used by recipes to upload to Amazon S3 or Rackspace Cloud Files.",
  :required => "optional",
  :choice => [ "S3", "CloudFiles" ],
  :recipes => ["repo::default"]

attribute "repo/default/storage_account_id",
  :display_name => "ROS Storage Account ID",
  :description => "In order to write the repository to the specified cloud storage location, you need to provide cloud authentication credentials. For Amazon S3, use your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME).",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/storage_account_secret",
  :display_name => "ROS Storage Account Secret",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY). For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY).",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/container",
  :display_name => "ROS Container",
  :description => "The cloud storage location where the dump file will be saved to or restored from. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/prefix",
  :display_name => "ROS Prefix",
  :description => "The prefix that will be used to name/locate the backup of a particular source repository. Defines the prefix of the source repo file name that will be used to name the downloaded repository file.",
  :required => "optional",
  :recipes => ["repo::default"]

#capistrano attributes used in repo::do_pull

attribute "repo/default/perform_action",
  :display_name => "Action",
  :description => "Choose the pull action which will be performed, 'pull'- standard repo pull, 'capistrano_pull' standard pull and then capistrano deployment style will be applied.",
  :choice => [ "pull", "capistrano_pull" ],
  :required => "recommended",
  :recipes => ["repo::do_pull"]


attribute "repo/default/destination",
  :display_name => "Project App root",
  :description => "Path to where project repo will be pulled",
  :required => "recommended",
  :recipes => ["repo::do_pull"]

