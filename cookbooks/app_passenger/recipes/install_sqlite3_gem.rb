# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


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