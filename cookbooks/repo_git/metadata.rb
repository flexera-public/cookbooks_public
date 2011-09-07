maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs Git's Fast Version Control System."
version          "0.0.1"

depends "git"

#provides "repo_git_pull(url, branch, dest, cred)" 
provides "repo_git"

