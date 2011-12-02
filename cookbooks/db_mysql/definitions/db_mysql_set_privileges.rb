#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
