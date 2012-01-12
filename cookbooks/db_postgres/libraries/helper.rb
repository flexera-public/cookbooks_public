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
    module PostgreSQL
      module Helper

        require 'timeout'
        require 'yaml'

        SNAPSHOT_POSITION_FILENAME = 'rs_snapshot_position.yaml'
        DEFAULT_CRITICAL_TIMEOUT = 7

        def mycnf_uuid
          node[:db_postgres][:mycnf_uuid] ||= Time.new.to_i
          node[:db_postgres][:mycnf_uuid]
        end

        def init(new_resource)
          begin
            require 'rightscale_tools'
          rescue LoadError
            Chef::Log.warn("This database cookbook requires our premium 'rightscale_tools' gem.")
            Chef::Log.warn("Please contact Rightscale to upgrade your account.")
          end
          mount_point = new_resource.name
          RightScale::Tools::Database.factory(:postgres, new_resource.user, new_resource.password, mount_point, Chef::Log)
        end

        def self.load_replication_info(node)
          loadfile = ::File.join(node[:db][:data_dir], SNAPSHOT_POSITION_FILENAME)
          Chef::Log.info "Loading replication information from #{loadfile}"
          YAML::load_file(loadfile)
        end

        # Configure the replication parameters into pg_hba.conf.
        def self.configure_pg_hba(node)
          File.open("/var/lib/pgsql/9.1/data/pg_hba.conf", "a") do |f|
            f.puts("host    replication     #{node[:db][:replication][:user]}          0.0.0.0/0            trust")
          end
          return $? == 0
        end

        def self.get_pgsql_handle(hostname = "localhost", username = "postgres")
          info_msg = "PostgreSQL connection to #{hostname}"
          info_msg << ": opening NEW PostgreSQL connection."
          conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)
          Chef::Log.info info_msg
          # this raises if the connection has gone away
          conn.ping
          return conn
        end

        def self.do_query(query, hostname = 'localhost', username = 'postgres', timeout = nil, tries = 1)
          require 'rubygems'
          Gem.clear_paths
          require 'pg'

          while(1) do
            begin
              info_msg = "Doing SQL Query: HOST=#{hostname}, QUERY=#{query}"
              info_msg << ", TIMEOUT=#{timeout}" if timeout
              info_msg << ", NUM_TRIES=#{tries}" if tries > 1
              Chef::Log.info info_msg
              result = nil
              if timeout
                  SystemTimer.timeout_after(timeout) do
                  conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)
                  result = conn.exec(query)
                end
              else
                conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)
                result = conn.exec(query)
              end
              return result.getvalue(0,0) if result
              return result
            rescue Timeout::Error => e
              Chef::Log.info("Timeout occured during pgsql query:#{e}")
              tries -= 1
              raise "FATAL: retry count reached" if tries == 0
            end
          end
        end

        def self.reconfigure_replication_info(newmaster_host = nil, rep_user = nil, rep_pass = nil, app_name = nil)
          File.open("/var/lib/pgsql/9.1/data/recovery.conf", File::CREAT|File::TRUNC|File::RDWR) do |f|
          f.puts("standby_mode='on'\nprimary_conninfo='host=#{newmaster_host} user=#{rep_user} password=#{rep_pass} application_name=#{app_name}'\ntrigger_file='/var/lib/pgsql/9.1/data/recovery.trigger'")
          `chown postgres:postgres /var/lib/pgsql/9.1/data/recovery.conf`
          end
          return $? == 0
        end

        # Configure the replication parameters into pg_hba.conf.
        def self.configure_postgres_conf(node)
          File.open("/var/lib/pgsql/9.1/data/postgresql.conf", "a") do |f|
            f.puts("synchronous_standby_names = '*'\nsynchronous_commit = on")
          end
          return $? == 0
        end

        def self.rsync_db(newmaster_host = nil, rep_user = nil)
          puts `su - postgres -c "env PGCONNECT_TIMEOUT=30 /usr/pgsql-9.1/bin/pg_basebackup -D /var/lib/pgsql/9.1/backups -U #{rep_user} -h #{newmaster_host}"`
          puts `su - postgres -c "rsync -av /var/lib/pgsql/9.1/backups/ /var/lib/pgsql/9.1/data --exclude postgresql.conf --exclude pg_hba.conf"`
          return $? == 0
        end

        def self.write_trigger(node)
          File.open("/var/lib/pgsql/9.1/data/recovery.trigger", File::CREAT|File::TRUNC|File::RDWR) do |f|
            f.puts(" ")
          end
        end

        def self.reconfigure_replication(hostname = 'localhost', newmaster_host = nil, newmaster_logfile=nil, newmaster_position=nil)
# These must be passed and not read from a file
#          master_info = RightScale::Database::PostgreSQL::Helper.load_replication_info(node)
#          newmaster_host = master_info['Master_IP']
#          newmaster_logfile = master_info['File']
#          newmaster_position = master_info['Position']
          Chef::Log.info "Configuring with #{newmaster_host} logfile #{newmaster_logfile} position #{newmaster_position}"

          # legacy did this twice, looks like slave stop can fail once (only throws warning if slave is already stopped)
          RightScale::Database::PostgreSQL::Helper.do_query("STOP SLAVE", hostname)
          RightScale::Database::PostgreSQL::Helper.do_query("STOP SLAVE", hostname)

          cmd = "CHANGE MASTER TO MASTER_HOST='#{newmaster_host}'"
          cmd = cmd +          ", MASTER_LOG_FILE='#{newmaster_logfile}'"
          cmd = cmd +          ", MASTER_LOG_POS=#{newmaster_position}"
          Chef::Log.info "Reconfiguring replication on localhost: \n#{cmd}"
          # don't log replication user and password
          cmd = cmd +          ", MASTER_USER='#{node[:db][:replication][:user]}'"
          cmd = cmd +          ", MASTER_PASSWORD='#{node[:db][:replication][:password]}'"
          RightScale::Database::PostgreSQL::Helper.do_query(cmd, hostname, username)

          RightScale::Database::PostgreSQL::Helper.do_query("START SLAVE", hostname, username)
          started=false
          10.times do
            row = RightScale::Database::PostgreSQL::Helper.do_query("SHOW SLAVE STATUS", hostname)
            slave_IO = row["Slave_IO_Running"].strip.downcase
            slave_SQL = row["Slave_SQL_Running"].strip.downcase
            if( slave_IO == "yes" and slave_SQL == "yes" ) then
              started=true
              break
            else
              Chef::Log.info "threads at new slave not started yet...waiting a bit more..."
              sleep 2
            end
          end
          if( started )
            Chef::Log.info "Slave threads on the master are up and running."
          else
            Chef::Log.info "Error: slave threads in the master do not seem to be up and running..."
          end
        end
      end
    end
  end
end
