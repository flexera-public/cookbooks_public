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
  :display_name => "Subversion User Name",
  :description => "",
  :required => false,
  :recipes => ['repo::do_pull_svn']

attribute "repo/svn/password",
  :display_name => "Subversion Password",
  :description => "",
  :required => false,
  :recipes => ['repo::do_pull_svn'] 

attribute "repo/svn/arguments",
  :display_name => "Subversion Arguments",
  :description => "",
  :required => false,
  :recipes => ['repo::do_pull_svn']

# grouping "repo/git",
#   :display_name => "Git"

attribute "repo/git/depth",
  :display_name => "Git Depth",
  :description => "",
  :default => nil,
  :required => false,
  :recipes => ['repo::do_pull_git']

attribute "repo/git/enable_submodules",
  :display_name => "Enable Submodules",
  :description => "",
  :default => "false",
  :required => false,
  :recipes => ['repo::do_pull_git']

attribute "repo/git/remote",
  :display_name => "Git Remote",
  :description => "",
  :default => "origin",
  :required => false,
  :recipes => ['repo::do_pull_git']

attribute "repo/git/ssh_key",
  :display_name => "Git SSH Key",
  :description => "",
  :default => nil,
  :required => false,
  :recipes => ['repo::do_pull_git']
  