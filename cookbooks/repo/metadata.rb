maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Pulls code from remote SCM repository"
version          "0.0.2"

depends "git"
depends "subversion"

provides "repo_pull(repo_type, destination)"
 
recipe  "repo::do_pull_git", "Pulls from a GIT repository."
recipe  "repo::do_pull_svn", "Pulls from a Subversion repository."

# grouping "repo",
#   :display_name => "Source Repository Settings"
  
attribute "repo/type",
  :display_name => "Repository Type",
  :description => "",
#  :choice => [ "Git", "Subversion" ],
  :required => true
  
attribute "repo/repository",
  :display_name => "Repository Url",
  :description => "",
  :required => true
  
attribute "repo/destination",
  :display_name => "Repository Destination",
  :description => "Where should I put the files?"
  
attribute "repo/revision",
  :display_name => "Revision/Branch/Tag",
  :description => "",
  :required => false

# grouping "repo/svn",
#   :display_name => "Subversion"

attribute "repo/svn/username",
  :display_name => "User Name (Subversion only)",
  :description => "",
  :required => false,
  :recipes => ['repo::do_pull_svn']

attribute "repo/svn/password",
  :display_name => "Password (Subversion only)",
  :description => "",
  :required => false,
  :recipes => ['repo::do_pull_svn'] 

attribute "repo/svn/arguments",
  :display_name => "Arguments  (Subversion only)",
  :description => "",
  :required => false,
  :recipes => ['repo::do_pull_svn']

# grouping "repo/git",
#   :display_name => "Git"

attribute "repo/git/depth",
  :display_name => "Depth (Git only)",
  :description => "",
  :default => nil,
  :required => false,
  :recipes => ['repo::do_pull_git']

attribute "repo/git/enable_submodules",
  :display_name => "Enable Submodules  (Git only)",
  :description => "",
  :default => "false",
  :required => false,
  :recipes => ['repo::do_pull_git']

attribute "repo/git/remote",
  :display_name => "Remote  (Git only)",
  :description => "",
  :default => "origin",
  :required => false,
  :recipes => ['repo::do_pull_git']

attribute "repo/git/ssh_key",
  :display_name => "SSH Key  (Git only)",
  :description => "",
  :default => nil,
  :required => false,
  :recipes => ['repo::do_pull_git']
  