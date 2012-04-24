#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

include RightScale::Database::MySQL::Helper

action :stop do
  service node[:db_mysql][:service_name] do
    action :stop
  end
end

action :start do
  service node[:db_mysql][:service_name] do
    action :start
  end
end

action :restart do
  service node[:db_mysql][:service_name] do
    action :restart
  end
end

action :status do
  @db = init(new_resource)
  status = @db.status
  log "Database Status:\n#{status}"
end

action :lock do
  @db = init(new_resource)
  @db.lock
end

action :unlock do
  @db = init(new_resource)
  @db.unlock
end

action :move_data_dir do
  @db = init(new_resource)
  @db.move_datadir
end

action :reset do
  @db = init(new_resource)
  @db.reset
end

action :firewall_update_request do
  sys_firewall "Request database open port 3306 (MySQL) to this server" do
    machine_tag new_resource.machine_tag
    port 3306 
    enable new_resource.enable
    ip_addr new_resource.ip_addr
    action :update_request
  end
end

action :firewall_update do
  sys_firewall "Request database open port 3306 (MySQL) to this server" do
    machine_tag new_resource.machine_tag
    port 3306 
    enable new_resource.enable
    action :update
  end
end


action :write_backup_info do
  masterstatus = Hash.new
  masterstatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW MASTER STATUS')
  masterstatus['Master_IP'] = node[:db][:current_master_ip]
  masterstatus['Master_instance_uuid'] = node[:db][:current_master_uuid]
  slavestatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW SLAVE STATUS')
  slavestatus ||= Hash.new
  if node[:db][:this_is_master]
    Chef::Log.info "Backing up Master info"
  else
    Chef::Log.info "Backing up slave replication status"
    masterstatus['File'] = slavestatus['Relay_Master_Log_File']
    masterstatus['Position'] = slavestatus['Exec_Master_Log_Pos']
  end

  # Save the db provider (MySQL) and version number as set in the node
  version=node[:db_mysql][:version]
  provider=node[:db][:provider]
  Chef::Log.info "  Saving #{provider} version #{version} in master info file"
  masterstatus['DB_Provider']=provider
  masterstatus['DB_Version']=version

  Chef::Log.info "Saving master info...:\n#{masterstatus.to_yaml}"
  ::File.open(::File.join(node[:db][:data_dir], RightScale::Database::MySQL::Helper::SNAPSHOT_POSITION_FILENAME), ::File::CREAT|::File::TRUNC|::File::RDWR) do |out|
    YAML.dump(masterstatus, out)
  end
end

action :pre_restore_check do
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

action :post_restore_cleanup do
  # Performs checks for snapshot compatibility with current server
  ruby_block "validate_backup" do
    block do
      master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)
      # Check version matches
      # Not all 11H2 snapshots (prior to 5.5 release) saved provider or version.  
      # Assume MySQL 5.1 if nil
      snap_version=master_info['DB_Version']||='5.1'
      snap_provider=master_info['DB_Provider']||='db_mysql'
      current_version= node[:db_mysql][:version]
      current_provider=master_info['DB_Provider']||=node[:db][:provider]
      Chef::Log.info "  Snapshot from #{snap_provider} version #{snap_version}"
      # skip check if restore version check is false
      if node[:db][:backup][:restore_version_check] == "true"
        raise "FATAL: Attempting to restore #{snap_provider} #{snap_version} snapshot to #{current_provider} #{current_version} with :restore_version_check enabled." unless ( snap_version == current_version ) && ( snap_provider == current_provider )
      else
        Chef::Log.info "  Skipping #{provider} restore version check"
      end
    end
  end

  @db = init(new_resource)
  @db.symlink_datadir("/var/lib/mysql", node[:db][:data_dir])
  @db.post_restore_cleanup
end

action :pre_backup_check do
  @db = init(new_resource)
  @db.pre_backup_check
end

action :post_backup_cleanup do
  @db = init(new_resource)
  @db.post_backup_steps
end

action :set_privileges do
  priv = new_resource.privilege
  priv_username = new_resource.privilege_username
  priv_password = new_resource.privilege_password
  priv_database = new_resource.privilege_database
  db_mysql_set_privileges "setup db privileges" do
    preset priv
    username priv_username
    password priv_password
    database priv_database
  end
end

action :install_client do

  # == Install MySQL client packages
  # Must install during the compile stage because mysql gem build depends on the libs
  if node[:platform] =~ /redhat|centos/
    # Install MySQL GPG Key (http://download.oracle.com/docs/cd/E17952_01/refman-5.5-en/checking-gpg-signature.html)
    gpgkey = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", "mysql_pubkey.asc")
    `rpm --import #{gpgkey}`
  end

  packages = node[:db_mysql][:client_packages_install]
  log "Packages to install: #{packages.join(",")}" unless packages == ""
  packages.each do |p|
    r = package p do
      action :nothing
    end
    r.run_action(:install)
  end

  # == Install MySQL client gem
  #
  # Also installs in compile phase
  #
  gem_package 'mysql' do
    gem_binary '/opt/rightscale/sandbox/bin/gem'
    version '2.7'
    options '-- --build-flags --with-mysql-config'
  end

  ruby_block 'clear gem paths for mysql' do
    block do
      Gem.clear_paths
    end
  end
  log "Gem reload forced with Gem.clear_paths"
end

action :install_server do

  # == Installing MySQL server
  #
  platform = node[:platform]
  # MySQL server depends on MySQL client
  action_install_client

  # == Uninstall other packages we don't
  #
  packages = node[:db_mysql][:packages_uninstall]
  log "Packages to uninstall: #{packages.join(",")}" unless packages == ""
  packages.each do |p|
     package p do
       action :remove
     end
  end unless packages == ""

  # == Install MySQL 5.1 and other packages
  #
  packages = node[:db_mysql][:server_packages_install]
  packages.each do |p|
    package p
  end unless packages == ""

  # == Stop mysql service 
  #
  db node[:db][:data_dir] do
    action [ :stop ]
    persist false
  end

  # Create MySQL server system tables
  touchfile = ::File.expand_path "~/.mysql_installed"
  execute "/usr/bin/mysql_install_db ; touch #{touchfile}" do
    creates touchfile
  end

  # moves mysql default db to storage location, removes ib_logfiles for re-config of innodb_log_file_size
  touchfile = ::File.expand_path "~/.mysql_dbmoved"
  ruby_block "clean innodb logfiles" do
    not_if { ::File.exists?(touchfile) }
    block do
      require 'fileutils'
      remove_files = ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ib_logfile*')) + ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ibdata*'))
      FileUtils.rm_rf(remove_files)
      ::File.open(touchfile,'a'){}
    end
  end

  # Initialize the binlog dir
  binlog = ::File.dirname(node[:db_mysql][:log_bin])
  directory binlog do
    owner "mysql"
    group "mysql"
    recursive true
  end

  # Create the tmp directory
  directory node[:db_mysql][:tmpdir] do
    owner "mysql"
    group "mysql"
    mode 0770
    recursive true
  end

  # Create it so mysql can use it if configured
  file "/var/log/mysqlslow.log" do
    owner "mysql"
    group "mysql"
  end

  # == Ensure that config directories exist
  #
  directory "/etc/mysql/conf.d" do
    owner "mysql"
    group "mysql"
    mode 0644
    recursive true
  end

  # Setup my.cnf
  template_source = "my.cnf.erb"
  template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
    source template_source
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => mycnf_uuid
    )
    cookbook 'db_mysql'
  end

  # == Setup MySQL user limits
  #
  mysql_file_ulimit = node[:db_mysql][:file_ulimit]
  template "/etc/security/limits.d/mysql.limits.conf" do
    source "mysql.limits.conf.erb"
    variables({
      :ulimit => mysql_file_ulimit
    })
    cookbook 'db_mysql'
  end

  # Change root's limitations for THIS shell.  The entry in the limits.d will be
  # used for future logins.
  # The setting needs to be in place before mysql is started.
  #
  execute "ulimit -n #{mysql_file_ulimit}"

  # == Setup custom mysqld init script via /etc/sysconfig/mysqld.
  #
  # Timeouts enabled.
  # Ubuntu's init script does not support configurable startup timeout
  #
  log_msg = ( platform =~ /redhat|centos/ ) ?  "  Setting mysql startup timeout" : "  Skipping mysql startup timeout setting for Ubuntu" 
  log log_msg
  template "/etc/sysconfig/#{node[:db_mysql][:service_name]}" do
    source "sysconfig-mysqld.erb"
    mode "0755"
    cookbook 'db_mysql'
    only_if { platform =~ /redhat|centos/ }
  end

  # == specific configs for ubuntu
  #  - set config file localhost access w/ root and no password
  #  - disable the 'check_for_crashed_tables'.
  #
  remote_file "/etc/mysql/debian.cnf" do
    only_if { platform == "ubuntu" }
    mode "0600"
    source "debian.cnf"
    cookbook 'db_mysql'
  end

  remote_file "/etc/mysql/debian-start" do
    only_if { platform == "ubuntu" }
    mode "0755"
    source "debian-start"
    cookbook 'db_mysql'
  end

  # == Fix permissions
  # During the first startup after install some of the file are created with root:root
  # so MySQL can not read them.
  dir=node[:db_mysql][:datadir]
  bash "chown mysql #{dir}" do
    flags "-ex"
    code <<-EOH
      chown -R mysql:mysql #{dir}
    EOH
  end

  # == Start MySQL
  #
  log "  Server installed.  Starting MySQL"
  db node[:db][:data_dir] do
    action [ :start ]
    persist false
  end

end

action :setup_monitoring do

  ruby_block "evaluate db type" do
    block do
      if node[:db][:init_status].to_s == "initialized"
        node[:db_mysql][:collectd_master_slave_mode] = ( node[:db][:this_is_master] == true ? "Master" : "Slave" ) + "Stats true"
      else
        node[:db_mysql][:collectd_master_slave_mode] = ""
      end
    end
  end

  service "collectd" do
    action :nothing
  end

  platform = node[:platform]
  # Centos specific items
  TMP_FILE = "/tmp/collectd.rpm"
  remote_file TMP_FILE do
    only_if { platform =~ /redhat|centos/ }
    source "collectd-mysql-4.10.0-4.el5.#{node[:kernel][:machine]}.rpm"
    cookbook 'db_mysql'
  end
  package TMP_FILE do
    only_if { platform =~ /redhat|centos/ }
    source TMP_FILE
  end

  template ::File.join(node[:rs_utils][:collectd_plugin_dir], 'mysql.conf') do
    source "collectd-plugin-mysql.conf.erb"
    mode "0644"
    backup false
    cookbook 'db_mysql'
    notifies :restart, resources(:service => "collectd")
  end

  # Send warning if not centos/redhat or ubuntu
  log "WARNING: attempting to install collectd-mysql on unsupported platform #{platform}, continuing.." do
    only_if { platform != "centos" && platform != "redhat" && platform != "ubuntu" }
    level :warn
  end

end

action :grant_replication_slave do
  require 'mysql'

  Chef::Log.info "GRANT REPLICATION SLAVE to #{node[:db][:replication][:user]}"
  con = Mysql.new('localhost', 'root')
  con.query("GRANT REPLICATION SLAVE ON *.* TO '#{node[:db][:replication][:user]}'@'%' IDENTIFIED BY '#{node[:db][:replication][:password]}'")
  con.query("FLUSH PRIVILEGES")
  con.close
end

action :promote do
  
  x = node[:db_mysql][:log_bin]
  logbin_dir = x.gsub(/#{::File.basename(x)}$/, "")
  directory logbin_dir do
    action :create
    recursive true
    owner 'mysql'
    group 'mysql'
  end

  # Set read/write in my.cnf
  node[:db_mysql][:tunable][:read_only] = 0
  # Enable binary logging in my.cnf
  node[:db_mysql][:log_bin_enabled] = true

  template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => mycnf_uuid
    )
    cookbook 'db_mysql'
  end
  
  db node[:db][:data_dir] do
    action :start
    persist false
    only_if do
      log_bin = RightScale::Database::MySQL::Helper.do_query(node, "show variables like 'log_bin'", 'localhost', RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT)
      if log_bin['Value'] == 'OFF'
      	Chef::Log.info "Detected binlogs were disabled, restarting service to enable them for Master takeover."
	      true
      else
      	false
      end
    end
  end

  RightScale::Database::MySQL::Helper.do_query(node, "SET GLOBAL READ_ONLY=0", 'localhost', RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT)
  newmasterstatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW SLAVE STATUS', 'localhost', RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT)
  previous_master = node[:db][:current_master_ip]
  raise "FATAL: could not determine master host from slave status" if previous_master.nil?
  Chef::Log.info "host: #{previous_master}}"

  # PHASE1: contains non-critical old master operations, if a timeout or
  # error occurs we continue promotion assuming the old master is dead.
  begin
    # OLDMASTER: query with terminate (STOP SLAVE)
    RightScale::Database::MySQL::Helper.do_query(node, 'STOP SLAVE', previous_master, RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT, 2)

    # OLDMASTER: flush_and_lock_db
    RightScale::Database::MySQL::Helper.do_query(node, 'FLUSH TABLES WITH READ LOCK', previous_master, 5, 12)


    # OLDMASTER:
    masterstatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW MASTER STATUS', previous_master, RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT)

    # OLDMASTER: unconfigure source of replication
    RightScale::Database::MySQL::Helper.do_query(node, "CHANGE MASTER TO MASTER_HOST=''", previous_master, RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT)

    master_file=masterstatus['File']
    master_position=masterstatus['Position']
    Chef::Log.info "Retrieved master info...File: " + master_file + " position: " + master_position

    Chef::Log.info "Waiting for slave to catch up with OLDMASTER (if alive).."
    # NEWMASTER localhost:
    RightScale::Database::MySQL::Helper.do_query(node, "SELECT MASTER_POS_WAIT('#{master_file}',#{master_position})")
  rescue => e
    Chef::Log.info "WARNING: caught exception #{e} during non-critical operations on the OLD MASTER"
  end

  # PHASE2: reset and promote this slave to master
  # Critical operations on newmaster, if a failure occurs here we allow it to halt promote operations
  Chef::Log.info "Promoting slave.."
  RightScale::Database::MySQL::Helper.do_query(node, 'RESET MASTER')

  newmasterstatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW MASTER STATUS')
  newmaster_file=newmasterstatus['File']
  newmaster_position=newmasterstatus['Position']
  Chef::Log.info "Retrieved new master info...File: " + newmaster_file + " position: " + newmaster_position

  Chef::Log.info "Stopping slave and misconfiguring master"
  RightScale::Database::MySQL::Helper.do_query(node, "STOP SLAVE")
  RightScale::Database::MySQL::Helper.do_query(node, "CHANGE MASTER TO MASTER_HOST='MASTER misconfigured on purpose during slave promotion'")
  action_grant_replication_slave
  RightScale::Database::MySQL::Helper.do_query(node, 'SET GLOBAL READ_ONLY=0')

  # PHASE3: more non-critical operations, have already made assumption oldmaster is dead
  begin
    unless previous_master.nil?
      #unlocking oldmaster
      RightScale::Database::MySQL::Helper.do_query(node, 'UNLOCK TABLES', previous_master)
      SystemTimer.timeout_after(RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT) do
	#demote oldmaster
        Chef::Log.info "Calling reconfigure replication with host: #{previous_master} ip: #{node[:cloud][:private_ips][0]} file: #{newmaster_file} position: #{newmaster_position}"
	RightScale::Database::MySQL::Helper.reconfigure_replication(node, previous_master, node[:cloud][:private_ips][0], newmaster_file, newmaster_position)
      end
    end
  rescue Timeout::Error => e
    Chef::Log.info("WARNING: rescuing SystemTimer exception #{e}, continuing with promote")
  rescue => e
    Chef::Log.info("WARNING: rescuing exception #{e}, continuing with promote")
  end
end


action :enable_replication do

  # Check the volume before performing any actions.  If invalid raise error and exit.
  ruby_block "validate_master" do
    block do
      master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)
      # Check that the snapshot is from the current master or a slave associated with the current master

      # 11H2 backup
      if master_info['Master_instance_uuid']
        if master_info['Master_instance_uuid'] != node[:db][:current_master_uuid]
          raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_uuid']} != current master: #{node[:db][:current_master_uuid]}"
        end
      # 11H1 backup
      elsif master_info['Master_instance_id']
        Chef::Log.info "  Detected 11H1 snapshot to migrate"
        if master_info['Master_instance_id'] != node[:db][:current_master_ec2_id]
          raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_id']} != current master: #{node[:db][:current_master_ec2_id]}"
        end
      # File not found or does not contain info
      else
        raise "Position and file not saved!"
      end
    end
  end

  ruby_block "wipe_existing_runtime_config" do
    block do
      Chef::Log.info "Wiping existing runtime config files"
      data_dir = ::File.join(node[:db][:data_dir], 'mysql')
      files_to_delete = [ "master.info","relay-log.info","mysql-bin.*","*relay-bin.*"]
      files_to_delete.each do |file|
        expand = Dir.glob(::File.join(data_dir,file))
        unless expand.empty?
        	expand.each do |exp_file|
        	  FileUtils.rm_rf(exp_file)
        	end
        end
      end
    end
  end

  # disable binary logging
  node[:db_mysql][:log_bin_enabled] = false

  # we refactored setup_my_cnf into db::install_server, we might want to break that out again?
  # Setup my.cnf
  template_source = "my.cnf.erb"

  template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
    source template_source
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => mycnf_uuid
    )
    cookbook 'db_mysql'
  end

  # empty out the binary log dir
  directory ::File.dirname(node[:db_mysql][:log_bin]) do
    action [:delete, :create]
    recursive true
    owner 'mysql'
    group 'mysql'
  end

  # ensure_db_started
  # service provider uses the status command to decide if it
  # has to run the start command again.
  10.times do
    db node[:db][:data_dir] do
      action :start
      persist false
    end
  end

  ruby_block "reconfigure_replication" do
    block do
      master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)
      newmaster_host = master_info['Master_IP']
      newmaster_logfile = master_info['File']
      newmaster_position = master_info['Position'] 
      RightScale::Database::MySQL::Helper.reconfigure_replication(node, 'localhost', newmaster_host, newmaster_logfile, newmaster_position)
    end
  end

  ruby_block "do_query" do
    block do
      RightScale::Database::MySQL::Helper.do_query(node, "SET GLOBAL READ_ONLY=1")
    end
  end

  node[:db_mysql][:tunable][:read_only] = 1
  template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
    source template_source
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => mycnf_uuid
    )
    cookbook 'db_mysql'
  end
end

action :generate_dump_file do

  db_name     = new_resource.db_name
  dumpfile    = new_resource.dumpfile

  execute "Write the mysql DB backup file" do
    command "mysqldump --single-transaction -u root #{db_name} | gzip -c > #{dumpfile}"
  end

end

action :restore_from_dump_file do
 
  db_name   = new_resource.db_name
  dumpfile  = new_resource.dumpfile
  db_check  = `mysql -e "SHOW DATABASES LIKE '#{db_name}'"`

  log "  Check if DB already exists"
  ruby_block "checking existing db" do
    block do
      if ! db_check.empty?
        Chef::Log.warn "WARNING: database '#{db_name}' already exists. No changes will be made to existing database."
      end
    end
  end
  
  bash "Import MySQL dump file: #{dumpfile}" do
    only_if { db_check.empty? }
    user "root"
    flags "-ex"
    code <<-EOH
      if [ ! -f #{dumpfile} ] 
      then 
        echo "ERROR: MySQL dumpfile not found! File: '#{dumpfile}'" 
        exit 1
      fi 
      mysqladmin -u root create #{db_name} 
      gunzip < #{dumpfile} | mysql -u root -b #{db_name}
    EOH
  end

end
