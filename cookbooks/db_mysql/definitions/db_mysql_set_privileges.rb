#
# Cookbook Name:: db_mysql
# Definition:: db_mysql_set_privileges
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

define :db_mysql_set_privileges, :preset => "administrator", :username => nil, :password => nil, :db_name => nil do

  priv_preset = params[:preset]
  username = params[:username]
  password = params[:password]
  db_name = "*.*"
  db_name = "#{params[:db_name]}.*" if params[:db_name]

  ruby_block "set admin credentials" do
    block do
      require 'rubygems'
      require 'mysql'

      con = Mysql.new("", "root",nil,nil,nil,"#{node[:db_mysql][:socket]}")

      # Now that we have a Mysql object, let's santize our inputs
      username = con.escape_string(username)
      password = con.escape_string(password)

      case priv_preset
      when 'administrator'
        con.query("GRANT ALL PRIVILEGES on *.* TO '#{username}'@'%' IDENTIFIED BY '#{password}' WITH GRANT OPTION")
        con.query("GRANT ALL PRIVILEGES on *.* TO '#{username}'@'localhost' IDENTIFIED BY '#{password}' WITH GRANT OPTION")
      when 'user'
        con.query("GRANT ALL PRIVILEGES on #{db_name} TO '#{username}'@'%' IDENTIFIED BY '#{password}'")
        con.query("GRANT ALL PRIVILEGES on #{db_name} TO '#{username}'@'localhost' IDENTIFIED BY '#{password}'")
        con.query("REVOKE SUPER on *.* FROM '#{username}'@'%' IDENTIFIED BY '#{password}'")
        con.query("REVOKE SUPER on *.* FROM '#{username}'@'localhost' IDENTIFIED BY '#{password}'")
      else
        raise "only 'administrator' and 'user' type presets are supported!"
      end

      con.query("FLUSH PRIVILEGES")
      con.close
    end
  end

end
