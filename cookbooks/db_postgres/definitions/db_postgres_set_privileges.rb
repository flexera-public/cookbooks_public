#
# Cookbook Name:: db_postgres
# Definition:: db_postgres_set_privileges
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

define :db_postgres_set_privileges, :preset => "administrator", :username => nil, :password => nil, :db_name => nil do 


  priv_preset = params[:preset]
  username = params[:username]
  password = params[:password]
  db_name = "*.*"
  db_name = "#{params[:db_name]}.*" if params[:db_name]
#  admin_role = params[:preset]
#  user_role = "users"

  ruby_block "set admin credentials" do
    block do
      require 'rubygems'
      Gem.clear_paths
      require 'pg'
	sleep 20
	conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)

      # Now that we have a Postgresql object, let's santize our inputs
      username = conn.escape_string(username)
      password = conn.escape_string(password)

      case priv_preset
      when 'administrator'
      # Create group roles, don't error out if already created.  Users don't inherit "special" attribs
      # from group role, see: http://www.postgresql.org/docs/9.1/static/role-membership.html 
      # cmd ==> createuser -h /var/run/postgresql -U postgres #{admin_role} -sdril 
      # conn.exec("CREATE ROLE #{admin_role} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN")
      
      # Enable admin/replication user
        result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username}'")
        userstat = result.getvalue(0,0)
        if ( userstat == '1' )
          Chef::Log.info "User #{username} already exists, updating user using current inputs"
          conn.exec("ALTER USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        else
          Chef::Log.info "creating administrator user #{username}"
          conn.exec("CREATE USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        end

      # Grant role previleges to admin/replication user
      # conn.exec("GRANT #{admin_role} TO #{username}")

      when 'user'
      # Create group roles, don't error out if already created.  Users don't inherit "special" attribs
      # from group role, see: http://www.postgresql.org/docs/9.1/static/role-membership.html
      # cmd ==> createuser -h /var/run/postgresql -U postgres #{user_role} -SdRil 
      #  conn.exec("CREATE ROLE #{user_role} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN")
      
      
      # Enable application user  
        result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username}'")
        userstat = result.getvalue(0,0)
        if ( userstat == '1' )
          Chef::Log.info "User #{username} already exists, updating user using current inputs"
          conn.exec("ALTER USER #{username} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        else
          Chef::Log.info "creating aplication user #{username}"
          conn.exec("CREATE USER #{username} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        end
      #  conn.exec("GRANT #{user_role} TO #{username}")

      # Set default privileges for any future tables, sequences, or functions created.
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username} GRANT ALL ON TABLES to #{username}")
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username} GRANT ALL ON SEQUENCES to #{username}")
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username} GRANT ALL ON FUNCTIONS to #{username}")

      else
        raise "only 'administrator' and 'user' type presets are supported!"
      end

      conn.finish
    end
  end

end
