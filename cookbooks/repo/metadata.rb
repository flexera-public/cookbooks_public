maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Pulls code from remote SCM repository"
version          "0.0.1"

depends "git"
depends "subversion"

provides "repo_pull(repo_type, destination)"
 
recipe  "repo::do_pull_git", "Pulls from a GIT repository."
recipe  "repo::do_pull_svn", "Pulls from a Subversion repository."

grouping "repo",
  :display_name => "Source Repository Settings"
  
attribute "repo/type",
  :display_name => "Repository Type",
  :description => "",
  :choice => [ "Git", "Subversion" ],
  :required => "required"
  
attribute "repo/repository",
  :display_name => "Repository Url",
  :description => "",
  :required => "required"
  
attribute "repo/revision",
  :display_name => "Revision/Branch/Tag",
  :description => "",
  :required => "recommended"

grouping "repo/svn",
  :display_name => "Subversion"

attribute "repo/svn/username",
  :display_name => "Subversion User Name",
  :description => "",
  :required => "optional"

attribute "repo/svn/password",
  :display_name => "Subversion Password",
  :description => "",
  :required => "optional"  

attribute "repo/svn/arguments",
  :display_name => "Subversion Arguments",
  :description => "",
  :required => "optional"

grouping "repo/git",
  :display_name => "Git"

attribute "repo/git/depth",
  :display_name => "Git Depth",
  :description => "",
  :default => nil,
  :required => "optional"

attribute "repo/git/enable_submodules",
  :display_name => "Enable Submodules",
  :description => "",
  :default => "false",
  :required => "optional"

attribute "repo/git/remote",
  :display_name => "Git Remote",
  :description => "",
  :default => "origin",
  :required => "optional"

attribute "repo/git/ssh_key",
  :display_name => "Git SSH Key",
  :description => "",
  :default => nil,
  :required => "optional"
  