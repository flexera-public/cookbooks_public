#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Setting provider specific settings for tomcat"

node[:app][:provider] = "app_tomcat"
node[:app][:database_name] = node[:tomcat][:db_name]
node[:app][:port] = 8000

case node[:platform]
when "ubuntu", "debian"
  case node[:tomcat][:db_adapter]
  when "mysql"
    node[:app][:packages] = [
      "ecj-gcj",
      #"java-gcj-compat-dev",
      "tomcat6",
      "tomcat6-admin",
      "tomcat6-common",
      "tomcat6-user",
      "libmysql-java",
      "libtcnative-1"
    ]
  when "postgresql"
    node[:app][:packages] = [
      "ecj-gcj",
      #"java-gcj-compat-dev",
      "tomcat6",
      "tomcat6-admin",
      "tomcat6-common",
      "tomcat6-user",
      "libtcnative-1"
    ]
  else
    raise "Unrecognized database adapter #{node[:tomcat][:db_adapter]}, exiting "
  end
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  case node[:tomcat][:db_adapter]
  when "mysql"
    node[:app][:packages] = [
      "eclipse-ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native",
      "mysql-connector-java"
    ]
  when "postgresql"
    node[:app][:packages] = [
      "eclipse-ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native"
    ]
  else
    raise "Unrecognized database adapter #{node[:tomcat][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

rs_utils_marker :end
