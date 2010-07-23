maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Manages the Git fast version control system"
version          "0.0.1"

provides "provider:repo" # not really in metadata spec yet. Format TBD.

recipe  "repo_git::default", "Default pattern of loading packages and resources provided"

grouping "repo/default",
 :display_name => "Git Client Default Settings",
 :description => "Settings for managing a Git source repository",
 :databag => true       # proposed metadata addition

attribute "repo/default/provider",
  :display_name => "Repository Provider Type",
  :description => "",
  :default => "repo_git"

attribute "repo/default/repository",
  :display_name => "Repository Url",
  :description => "",
  :required => true
  
attribute "repo/default/branch",
  :display_name => "Branch/Tag",
  :description => "",
  :required => false

attribute "repo/default/depth",
  :display_name => "Depth",
  :description => "",
  :default => nil,
  :required => false

attribute "repo/default/enable_submodules",
  :display_name => "Enable Submodules",
  :description => "",
  :default => "false",
  :required => false

attribute "repo/default/remote",
  :display_name => "Remote",
  :description => "",
  :default => "origin",
  :required => false
  
attribute "repo/default/ssh_key",
  :display_name => "SSH Key",
  :description => "",
  :default => nil,
  :required => false
  