# Cookbook Name:: db_mysql
# Recipe:: install_client_5.0
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


# == Install MySQL 5.0 package
#
# install client in converge phase
package "mysql-client" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse" ] => { "default" => "mysql" },
    "default" => "mysql-client"
  )
  action :install
end

if node[:platform] == "ubuntu"
  # Install development library in compile phase
  p = package "mysql-dev" do
    package_name value_for_platform(
      "ubuntu" => {
        "8.04" => "libmysqlclient15-dev",
        "8.10" => "libmysqlclient15-dev",
        "9.04" => "libmysqlclient15-dev"
      },
      "default" => 'libmysqlclient-dev'
    )
    action :nothing
  end
  p.run_action(:install)

end


# == Install MySQL client gem
#
# Also installs in compile phase
#
r = execute "install mysql gem" do
  command "/opt/rightscale/sandbox/bin/gem install mysql --no-rdoc --no-ri -v 2.7 -- --build-flags --with-mysql-config"
end
r.run_action(:run)

Gem.clear_paths
log "Gem reload forced with Gem.clear_paths"

# == Install "perl-DBD-MySQL"
# 
#TODO
