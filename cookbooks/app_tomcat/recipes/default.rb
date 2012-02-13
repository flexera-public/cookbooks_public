# Cookbook Name:: app_tomcat
# Recipe:: default
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "default empty recipe for attributes initialization"

=begin
  node[:tomcat][:package_dependencies].each do |p|
    log "installing #{p}"
    package p

    # eclipse-ecj and symlink must be installed FIRST
    if p=="eclipse-ecj" || "ecj-gcj"
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
  
  # Link mysql-connector plugin to Tomcat6 lib
  file "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
    action :delete
  end

  link "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
    to "/usr/share/java/mysql-connector-java.jar"
  end

  # "Linking RightImage JAVA_HOME to what Tomcat6 expects to be..."
  link "/usr/lib/jvm/java" do
    to "/usr/java/default"
  end


  # Moving tomcat logs to mnt
  if ! File.directory?("/mnt/log/tomcat6") 
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
  
        if test "$jboss_archive" = "" ; then
          ln -s $java_dir java
        fi
      fi
    EOH
  end
=end
rs_utils_marker :end
