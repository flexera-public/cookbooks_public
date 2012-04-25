#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :stop do
  log "  Running stop sequence"
  service "tomcat6" do
    action :stop
    persist false
  end
end

action :start do
  log "  Running start sequence"
  service "tomcat6" do
    action :start
    persist false
  end

end

action :restart do
  log "  Running restart sequence"
  action_stop
     sleep 5
  action_start
end


#Installing required packages and prepare system for tomcat
action :install do

  packages = new_resource.packages
  log "  Packages which will be installed: #{packages}"
  packages .each do |p|
    log "installing #{p}"
    package p

    # eclipse-ecj and symlink must be installed FIRST
    if p=="eclipse-ecj" || p=="ecj-gcj"
      file "/usr/share/java/ecj.jar" do
        action :delete
      end

      link "/usr/share/java/ecj.jar" do
        to "/usr/share/java/eclipse-ecj.jar"
      end

    end
  end

  execute "alternatives" do
    command "#{node[:tomcat][:alternatives_cmd]}"
    action :run
  end

  db_adapter = node[:tomcat][:db_adapter]
  if db_adapter == "mysql"
    # Link mysql-connector plugin to Tomcat6 lib
    file "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
      action :delete
    end

    link "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
      to "/usr/share/java/mysql-connector-java.jar"
    end
  elsif db_adapter == "postgresql"
    # Copy to /usr/share/java/postgresql-9.1-901.jdbc4.jar
    remote_file "/usr/share/java/postgresql-9.1-901.jdbc4.jar" do
      source "postgresql-9.1-901.jdbc4.jar"
      owner "root"
      group "root"
      cookbook 'app_tomcat'
    end
    ## Link postgresql-connector plugin to Tomcat6 lib
    link "/usr/share/tomcat6/lib/postgresql-9.1-901.jdbc4.jar" do
      to "/usr/share/java/postgresql-9.1-901.jdbc4.jar"
    end
  else
    raise "Unrecognized database adapter #{node[:tomcat][:db_adapter]}, exiting "
  end

  # "Linking RightImage JAVA_HOME to what Tomcat6 expects to be..."
  link "/usr/lib/jvm/java" do
    to "/usr/java/default"
  end


  # Moving tomcat logs to mnt
  if ! ::File.directory?("/mnt/log/tomcat6")
    directory "/mnt/log/tomcat6" do
      owner node[:tomcat][:app_user]
      group node[:tomcat][:app_user]
      mode "0755"
      action :create
      recursive true
    end

    directory "/var/log/tomcat6" do
      action :delete
      recursive true
    end

    link "/var/log/tomcat6" do
      to "/mnt/log/tomcat6"
    end
  end

  bash "Create /usr/lib/jvm-exports/java if possible" do
    flags "-ex"
    code <<-EOH
      if [ -d "/usr/lib/jvm-exports" ] && [ ! -d "/usr/lib/jvm-exports/java" ]; then
        cd /usr/lib/jvm-exports
        java_dir=`ls -d java-* -1 2>/dev/null | tail -1`

        if ! test "$java_dir" = "" ; then
          ln -s $java_dir java
        fi
      fi
    EOH
  end

  ENV['APP_NAME'] = node[:web_apache][:application_name]
  bash "save global vars" do
    flags "-ex"
    code <<-EOH
      echo $APP_NAME >> /tmp/appname
    EOH
  end

end

# Setup apache virtual host and corresponding tomcat configs
action :setup_vhost do

  log "  Creating tomcat6.conf"
  template "/etc/tomcat6/tomcat6.conf" do
    action :create
    source "tomcat6_conf.erb"
    group "root"
    owner "root"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
      :app_user => node[:tomcat][:app_user],
      :java_xms => node[:tomcat][:java][:xms],
      :java_xmx => node[:tomcat][:java][:xms],
      :java_permsize => node[:tomcat][:java][:permsize],
      :java_maxpermsize => node[:tomcat][:java][:maxpermsize],
      :java_newsize => node[:tomcat][:java][:newsize],
      :java_maxnewsize => node[:tomcat][:java][:maxnewsize]
    )
  end

  log "  Creating server.xml"
  template "/etc/tomcat6/server.xml" do
    action :create
    source "server_xml.erb"
    group "root"
    owner "#{node[:tomcat][:app_user]}"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
            :doc_root => node[:tomcat][:docroot]
          )
  end

  log "  Setup logrotate for tomcat"
  template "/etc/logrotate.d/tomcat6" do
    source "tomcat6_logrotate.conf.erb"
    variables :tomcat_name => "tomcat6"
    cookbook 'app_tomcat'
  end


    action_start

  log "  Setup mod_jk vhost"
  # Setup mod_jk vhost start
  etc_apache = "/etc/#{node[:apache][:config_subdir]}"

  # Check if mod_jk is installed
  if !::File.exists?("#{etc_apache}/conf.d/mod_jk.conf")

    arch = node[:kernel][:machine]
    connectors_source = "tomcat-connectors-1.2.32-src.tar.gz"

    case node[:platform]
      when "ubuntu", "debian"
        ubuntu_p = ["apache2-mpm-prefork", "apache2-threaded-dev", "libapr1-dev", "libapache2-mod-jk"]
        ubuntu_p.each do |p|
          package p
        end

      when "centos","fedora","suse","redhat"
        if arch == "x86_64"
          bash "install_remove" do
            flags "-ex"
            code <<-EOH
              yum install apr-devel.x86_64 -y
            EOH
          end
        end

        package "httpd-devel" do
          options "-y"
        end

      cookbook_file "/tmp/#{connectors_source}" do
        source "#{connectors_source}"
        cookbook 'app_tomcat'
      end

      bash "install_tomcat_connectors" do
      flags "-ex"
        code <<-EOH
          cd /tmp
          mkdir -p /tmp/tc-unpack
          tar xzf #{connectors_source} -C /tmp/tc-unpack --strip-components=1

          cd tc-unpack/native
          ./buildconf.sh
          ./configure --with-apxs=/usr/sbin/apxs --quiet
          make -s
          su -c 'make install'
        EOH
      end

    end

    # Configure workers.properties for mod_jk
    template "/etc/tomcat6/workers.properties" do
      action :create
      source "tomcat_workers.properties.erb"
      variables(
      :tomcat_name => "tomcat6",
      :config_subdir => node[:apache][:config_subdir]
      )
      cookbook 'app_tomcat'
    end

    # Configure mod_jk conf
    template "#{etc_apache}/conf.d/mod_jk.conf" do
      action :create
      backup false
      source "mod_jk.conf.erb"
      variables :tomcat_name => "tomcat6"
      cookbook 'app_tomcat'
    end

    log "Finished configuring mod_jk, creating the application vhost..."

    # Enabling required apache modules
    node[:tomcat][:module_dependencies].each do |mod|
      apache_module mod
    end

    # Apache fix on RHEL
    file "/etc/httpd/conf.d/README" do
      action :delete
      only_if do node[:platform] == "redhat" end
    end

    log "  Generating new apache ports.conf"
    node[:apache][:listen_ports] = "80"

    template "#{node[:apache][:dir]}/ports.conf" do
      cookbook "apache2"
      source "ports.conf.erb"
      variables :apache_listen_ports => node[:apache][:listen_ports]
    end

     # Configuring document root for apache
    if ("#{node[:tomcat][:code][:root_war]}" == "")
      log "root_war not defined, setting apache docroot to #{node[:tomcat][:docroot]}"
      docroot4apache = "#{node[:tomcat][:docroot]}"
    else
      log "root_war defined, setting apache docroot to #{node[:tomcat][:docroot]}/ROOT"
      docroot4apache = "#{node[:tomcat][:docroot]}/ROOT"
    end

    port = new_resource.port


    log "  Configuring apache vhost for tomcat"
    template "#{etc_apache}/sites-enabled/#{node[:web_apache][:application_name]}.conf" do
      action :create_if_missing
      source "apache_mod_jk_vhost.erb"
      variables(
        :docroot     => docroot4apache,
        :vhost_port  => port.to_s,
        :server_name => node[:web_apache][:server_name],
        :apache_log_dir => node[:apache][:log_dir]
      )
      cookbook 'app_tomcat'
    end

    service "#{node[:apache][:config_subdir]}" do
      action :restart
      persist false
    end

  else
    log "  mod_jk already installed, skipping the recipe"
  end

end

# Setup project db connection
action :setup_db_connection do

  db_name = new_resource.database_name
  db_adapter = node[:tomcat][:db_adapter]
  
  log "  Creating context.xml"
  if db_adapter == "mysql"  
    db_mysql_connect_app "/etc/tomcat6/context.xml"  do
      template      "context_xml.erb"
      owner         "#{node[:tomcat][:app_user]}"
      group         "root"
      mode          "0644"
      database      db_name
      cookbook      'app_tomcat'
    end
  elsif db_adapter == "postgresql"  
    db_postgres_connect_app "/etc/tomcat6/context.xml"  do
      template      "context_xml.erb"
      owner         "#{node[:tomcat][:app_user]}"
      group         "root"
      mode          "0644"
      database      db_name
      cookbook      'app_tomcat'
    end
  else
    raise "Unrecognized database adapter #{node[:tomcat][:db_adapter]}, exiting "
  end

  log "  Creating context.xml"
  template "/etc/tomcat6/web.xml" do
    source "web_xml.erb"
    owner "#{node[:tomcat][:app_user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end

  cookbook_file "/usr/share/tomcat6/lib/jstl-api-1.2.jar" do
    source "jstl-api-1.2.jar"
    owner "#{node[:tomcat][:app_user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end


  cookbook_file "/usr/share/tomcat6/lib/jstl-impl-1.2.jar" do
    source "jstl-impl-1.2.jar"
    owner "#{node[:tomcat][:app_user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end
end

# Setup monitoring tools for tomcat
action :setup_monitoring do

  log "  Setup of collectd monitoring for tomcat"
  rs_utils_enable_collectd_plugin 'exec'

  #installing and configuring collectd for tomcat
  cookbook_file "/usr/share/java/collectd.jar" do
    source "collectd.jar"
    mode "0644"
    cookbook 'app_tomcat'
  end

  #Linking collectd
  link "/usr/share/tomcat6/lib/collectd.jar" do
    to "/usr/share/java/collectd.jar"
    not_if do !::File.exists?("/usr/share/java/collectd.jar") end
  end

  #Add collectd support to tomcat.conf
  bash "Add collectd to tomcat.conf" do
    flags "-ex"
    code <<-EOH
      cat <<'EOF'>>/etc/tomcat6/tomcat6.conf
      CATALINA_OPTS="\$CATALINA_OPTS -Djcd.host=#{node[:rightscale][:instance_uuid]} -Djcd.instance=tomcat6 -Djcd.dest=udp://#{node[:rightscale][:servers][:sketchy][:hostname]}:3011 -Djcd.tmpl=javalang,tomcat -javaagent:/usr/share/tomcat6/lib/collectd.jar"
      EOF
    EOH
  end


end

#Download/Update application repository
action :code_update do

  log "  Starting code update sequence"
  # Check that we have the required attributes set
  raise "You must provide a destination for your application code." if ("#{node[:tomcat][:docroot]}" == "")

  # Reading app name from tmp file (for execution in "operational" phase))
  # Waiting for "run_lists"
  deploy_dir = node[:tomcat][:docroot]
  if(deploy_dir == "/srv/tomcat6/webapps/")
    app_name = IO.read('/tmp/appname')
    deploy_dir = "/srv/tomcat6/webapps/#{app_name.to_s.chomp}"

  end

  directory "/srv/tomcat6/webapps/" do
    recursive true
  end

  log "  Downloading project repo"
  repo "default" do
    destination deploy_dir
    action :capistrano_pull
    app_user node[:tomcat][:app_user]
    persist false
  end

  log "  Set ROOT war and code ownership"
  bash "set_root_war_and_chown_home" do
    flags "-ex"
    code <<-EOH
      cd #{node[:tomcat][:docroot]}
      if [ ! -z "#{node[:tomcat][:code][:root_war]}" -a -e "#{node[:tomcat][:docroot]}/#{node[:tomcat][:code][:root_war]}" ] ; then
        mv #{node[:tomcat][:docroot]}/#{node[:tomcat][:code][:root_war]} #{node[:tomcat][:docroot]}/ROOT.war
      fi
      chown -R #{node[:tomcat][:app_user]}:#{node[:tomcat][:app_user]} #{node[:tomcat][:docroot]}
      sleep 5
    EOH
    only_if do node[:tomcat][:code][:root_war] != "ROOT.war" end
  end

  action_restart

  node[:delete_docroot_executed] = true

end
