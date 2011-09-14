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

module RightScale
  module Database
    module MySQL
      module Helper
	require 'timeout'
	require 'yaml'

	SNAPSHOT_POSITION_FILENAME = 'rs_snapshot_position.yaml'

        def init(new_resource)
          begin
            require 'rightscale_tools'
          rescue LoadError
            Chef::Log.warn("This database cookbook requires our premium 'rightscale_tools' gem.")
            Chef::Log.warn("Please contact Rightscale to upgrade your account.")
          end
          mount_point = new_resource.name
          RightScale::Tools::Database.factory(:mysql, new_resource.user, new_resource.password, mount_point, Chef::Log)
        end

	def self.load_replication_info(node)
	  loadfile = ::File.join(node[:db][:data_dir], SNAPSHOT_POSITION_FILENAME)
	  Chef::Log.info "Loading replication information from #{loadfile}"
	  YAML::load_file(loadfile)
	end

	def self.get_mysql_handle(node, hostname = 'localhost')
	  info_msg = "MySQL connection to #{hostname}"
	  info_msg << ": opening NEW MySQL connection."
	  con = Mysql.new(hostname, node[:db][:admin][:user], node[:db][:admin][:password])
	  Chef::Log.info info_msg
	  # this raises if the connection has gone away
	  con.ping
	  return con
	end

	def self.do_query(node, query, hostname = 'localhost', timeout = nil, tries = 1)
	  require 'mysql'

	  while(1) do
	    begin
	      info_msg = "Doing SQL Query: HOST=#{hostname}, QUERY=#{query}"
	      info_msg << ", TIMEOUT=#{timeout}" if timeout
	      info_msg << ", NUM_TRIES=#{tries}" if tries > 1
	      Chef::Log.info info_msg
	      result = nil
	      if timeout
		SystemTimer.timeout_after(timeout) do
		  con = get_mysql_handle(node, hostname)
		  result = con.query(query)
		end
	      else
		con = get_mysql_handle(node, hostname)
		result = con.query(query)
	      end
	      return result.fetch_hash if result
	      return result
	    rescue Timeout::Error => e
	      Chef::Log.info("Timeout occured during mysql query:#{e}")
	      tries -= 1
	      raise "FATAL: retry count reached" if tries == 0
	    end
	  end
	end
      end
    end
  end
end
