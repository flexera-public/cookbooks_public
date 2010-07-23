maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Abstract cookbook for managing source code repositories."
long_description "Provides a chef lightweight resource called 'repo' as a Bridge to repo_svn and repo_git cookbooks."
version          "0.0.1"

provides "resource:repo"  # not really in metadata spec yet. Format TBD.
  
  