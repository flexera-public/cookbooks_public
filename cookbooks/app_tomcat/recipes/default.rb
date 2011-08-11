# Cookbook Name:: app_tomcat
# Recipe:: default

# TODO - changes if not centos (ie ubuntu)
# TEST - currently only for centos
#case node[:platform]
#when "centos","fedora","suse"

  node[:tomcat][:package_dependencies].each do |p|
    log "installing #{p}"
    package p

    # eclipse-ecj and symlink must be installed FIRST
    if p=="eclipse-ecj"
      # ln -sf /usr/share/java/eclipse-ecj.jar /usr/share/java/ecj.jar
      # todo: if /usr/share/java/ecj.jar exists delete first
      link "/usr/share/java/ecj.jar" do
        to "/usr/share/java/eclipse-ecj.jar"
      end
    end
  end

  execute "alternatives" do
    command "alternatives --auto java"
    action :run
  end
  
  ## Link mysql-connector plugin to Tomcat6 lib
  # ln -sf /usr/share/java/mysql-connector-java.jar /usr/share/tomcat6/lib/mysql-connector-java.jar
  # todo: if /usr/share/tomcat6/lib/mysql-connector-java.jar exists delete it first
  link "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
    to "/usr/share/java/mysql-connector-java.jar"
  end

  ## "Linking RightImage JAVA_HOME to what Tomcat6 expects to be..."
  # ln -nfs $java_home $tc_java_home
  # ln -nfs /usr/java/default /usr/lib/jvm/java
  link "/usr/lib/jvm/java" do
    to "/usr/java/default"
  end


  # Moving tomcat logs to mnt
  if ! File.directory?("/mnt/log/tomcat6") 
    directory "/mnt/log/tomcat6" do
      owner "tomcat"
      group "tomcat"
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

#else
#    log "nothing done yet for non centos"
#end
