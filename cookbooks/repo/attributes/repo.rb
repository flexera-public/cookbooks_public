case repo[:type]
when "Git"
  set[:repo][:type] = :git
when "Subversion"
  set[:repo][:type] = :svn
else
  raise ArgumentError, "You must select 'Git' or 'Subversion' for repo[:type]."
end

default[:repo][:destination] = nil
default[:repo][:repository] = nil
default[:repo][:revision] = nil

default[:repo][:svn][:username] = nil
default[:repo][:svn][:password] = nil
default[:repo][:svn][:arguments] = nil

default[:repo][:git][:depth] = nil 	    
default[:repo][:git][:enable_submodules] = false	
default[:repo][:git][:remote] = "origin"	    
default[:repo][:git][:ssh_key] = nil	