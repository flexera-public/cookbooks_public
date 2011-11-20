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
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
#
rs_utils_marker :begin

#
# For normal installation of sqlite3 gem we need to install sqlite 3.6.6+ instead sqlite 3.3.+ bundled with CentOS
#
case node[:platform]
  when "centos","redhat","redhatenterpriseserver","fedora","suse"
    node[:app_passenger][:sqlite_packages_install]= ["zlib-devel", "sqlite-devel"]
   #installing packages required foe compilation
    node[:app_passenger][:sqlite_packages_install].each do |p|
      package p
    end

    #Extracting cookbook file
    cookbook_file "/tmp/sqlite-3.7.0.1.tgz" do
      source "sqlite-3.7.0.1.tgz"
      mode "0644"
    end

    #Unpacking
    bash "unpack sqlite3" do
      code <<-EOH
        tar xzf /tmp/sqlite-3.7.0.1.tgz -C /tmp/
      EOH
      only_if do File.exists?("/tmp/sqlite-3.7.0.1.tgz")  end
    end

    #Compiling sqlite3
    bash "compile sqlite3" do
      cwd "/tmp/sqlite-3.7.0.1/"
      code <<-EOH
        make install
      EOH
      only_if do File.exists?("/tmp/sqlite-3.7.0.1/configure")  end
    end

    #Installing sqlite3 gem
    log"INFO: Installing sqlite3 gem"
    gem_package "sqlite3" do
      options " -- --with-sqlite3-dir=/opt/local/sqlite-3.7.0.1 -v 1.3.4"
      gem_binary node[:app_passenger][:gem_bin]
    end

  log "Gem reload forced with Gem.clear_paths"


  when "ubuntu","debian"

    gem_package "sqlite3" do
      gem_binary node[:app_passenger][:gem_bin]
    end

end

rs_utils_marker :end