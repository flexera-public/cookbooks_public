#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class Ssh_key
     KEYFILE = "/tmp/gitkey"

     # Add ssh key and exec script
     def create(ssh_key)
       Chef::Log.info("Creating ssh key")

       keyfile = nil
       keyname = ssh_key
       if "#{keyname}" != ""
         keyfile = KEYFILE
         system("echo -n '#{keyname}' > #{keyfile}")
         system("chmod 700 #{keyfile}")
         system("echo 'exec ssh -oStrictHostKeyChecking=no -i #{keyfile} \"$@\"' > #{keyfile}.sh")
         system("chmod +x #{keyfile}.sh")
       end

       ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
     end

     # Delete SSH key & clear GIT_SSH
     def delete
       Chef::Log.warn "Deleting ssh key "
        keyfile = KEYFILE
       if keyfile != nil
         system("rm -f #{keyfile}")
         system("rm -f #{keyfile}.sh")
       end
     end

    end
  end
end
