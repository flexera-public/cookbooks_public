#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Install specified gems

# Variable node[:app_passenger][:opt_gems_list] contains space separated list of Gems along
# with their versions in the format:
#
#   ruby-Gem1:version  ruby-Gem2:version ruby-Gem3:version
#
log "  Installing user specified gems:"
ruby_block "Install custom gems" do
  block do

    gem_list = node[:app_passenger][:project][:gem_list]

    #split gem_list into an array
    gem_list = gem_list.split

    gem_list.each do |gem_name|
      begin
        if gem_name =~ /(.+):([\d\.]{2,})/
          name = "#{$1} --version #{$2}"
        else
          name = gem_name
        end
      end
      raise "Error installing gems!" unless
      system("#{node[:app_passenger][:gem_bin].chomp} install #{name} --no-ri --no-rdoc --no-update-sources")
    end

  end
   only_if do (node[:app_passenger][:project][:gem_list]!="") end
end

rs_utils_marker :end
