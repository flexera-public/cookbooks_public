#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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

        # This is a check to verify node is master server
        def self.detect_if_slave(node)
          read_only = `/usr/pgsql-9.1/bin/pg_controldata /var/lib/pgsql/9.1/data | grep "Database cluster state" | awk '{print $NF}'`
          return true if read_only =~ /recovery/
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

      end
    end
  end
end
