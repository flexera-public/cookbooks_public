# include the public recipe to install git
include_recipe "git"
 
# add ssh key and exec script
keyfile = nil
if "#{@node[:repo][:git][:ssh_key]}" != ""
  keyfile = "/tmp/gitkey"
  bash 'create_temp_git_ssh_key' do
    code <<-EOH
      echo -n '#{@node[:repo][:git][:ssh_key]}' > #{keyfile}
      chmod 700 #{keyfile}
      echo 'exec ssh -oStrictHostKeyChecking=no -i #{keyfile} "$@"' > #{keyfile}.sh
      chmod +x #{keyfile}.sh
    EOH
  end
end 

# scm "pull git repository" do
#   destination @node[:repo][:destination]
#   repository @node[:repo][:repository]
#   revision @node[:repo][:revision]
#   
#   depth @node[:repo][:git][:depth]    
#   enable_submodules @node[:repo][:git][:enable_submodules] 
#   remote @node[:repo][:git][:remote]     
#    
#   ssh_wrapper "#{keyfile}.sh" if keyfile    
#   
#   provider Chef::Provider::Git
# end

# pull repo (if exist)
ruby "pull-exsiting-local-repo" do
  cwd @node[:repo][:destination]
  only_if do File.directory?(@node[:repo][:destination]) end
  code <<-EOH
    puts "Updateing existing repo at #{@node[:repo][:destination]}"
    ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
    puts `git pull` 
  EOH
end

# clone repo (if not exist)
ruby "create-new-local-repo" do
  not_if do File.directory?(@node[:repo][:destination]) end
  code <<-EOH
    puts "Creating new repo at #{@node[:repo][:destination]}"
    ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
    puts `git clone #{@node[:repo][:repository]} -- #{@node[:repo][:destination]}`

    if "#{@node[:repo][:revision]}" != "master" 
      dir = "#{@node[:repo][:destination]}"
      Dir.chdir(dir) 
      puts `git checkout --track -b #{@node[:repo][:revision]} origin/#{params[:repo][:revision]}`
    end
  EOH
end

# delete SSH key & clear GIT_SSH
if keyfile != nil
   bash 'delete_temp_git_ssh_key' do
     code <<-EOH
       rm -f #{keyfile}
       rm -f #{keyfile}.sh
     EOH
   end
end