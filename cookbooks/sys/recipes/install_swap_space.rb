#
# Cookbook Name:: sys
# Recipe:: install_swap_space
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
# Cookbook Name:: app_tomcat
# Recipe:: default

# TODO - changes if not centos (ie ubuntu)
# TEST - currently only for centos
#case node[:platform]
#when "centos","fedora","suse"

  script 'create swapfile' do
    interpreter 'bash'
    not_if { File.exists?('/swapfile') }
    code <<-eof
      dd if=/dev/zero of=/var/swapfile bs=1M count=2048 &&
      chmod 600 /swapfile &&
      mkswap /swapfile &&
    eof
  end

#echo "/swapfile  swap      swap    defaults        0 0" >> /etc/fstab

  mount '/dev/null' do  # swap file entry for fstab
    action :enable  # cannot mount; only add to fstab
    device '/swapfile'
    fstype 'swap'
  end
   
  script 'activate swap' do
    interpreter 'bash'
    code 'swapon /swapfile'
  end
