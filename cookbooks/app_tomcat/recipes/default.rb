# Cookbook Name:: app_tomcat
# Recipe:: default
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

rs_utils_marker :begin

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

#else
#    log "nothing done yet for non centos"
#end

rs_utils_marker :end
