# Cookbook Name:: app_passenger
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

rs_utils_marker :begin

# Install specified gems
#
# Variable node[:app_passenger][:opt_gems_list] contains space separated list of Gems along
# with their versions in the format:
#
#   ruby-Gem1:version  ruby-Gem2:version ruby-Gem3:version
#
  log "Installing user specified gems:"
ruby_block "Install custom gems" do
  block do
    gem_list = node[:app_passenger][:opt_gems_list]

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
   only_if do (node[:app_passenger][:opt_gems_list]!="") end
end

rs_utils_marker :end
