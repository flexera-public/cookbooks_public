#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Only setup remote logging for ec2 clouds.  
#
# Can not setup other clouds until they have access to our lumberjack servers.
# All non-ec2 clouds will use default syslog-ng configuration
#
if "#{node[:rightscale][:servers][:lumberjack][:hostname]}" != "" && node[:rs_utils][:enable_remote_logging] == true
  
  rs_utils_marker :begin

  log "Configure remote syslog logging"

  # == Make sure syslog-ng is installed.
  #
  package "syslog-ng"

  service "syslog-ng" do
    supports :start => true, :stop => true, :restart => true
    action [ :enable ]
  end

  # == Create a new /dev/null for syslog-ng to use
  #
  execute "ensure_dev_null" do
    creates "/dev/null.syslog-ng"
    command "mknod /dev/null.syslog-ng c 1 3"
  end

  # == Configure syslog
  #
  template "/etc/syslog-ng/syslog-ng.conf" do
    source "syslog.erb"
    variables ({
      :apache_log_dir => (node[:platform] =~ /redhat|centos/) ? "httpd" : "apache2"
    })
    notifies :restart, resources(:service => "syslog-ng")
  end

  # == Ensure everything in /var/log is owned by root, not syslog.
  #
  Dir.glob("/var/log/*").each do |f|
    if ::File.directory?(f)
      
      directory f do 
        owner "root" 
        notifies :restart, resources(:service => "syslog-ng")
      end
      
    else
      
      file f do 
        owner "root" 
        notifies :restart, resources(:service => "syslog-ng")
      end
    
    end
  end

  # == Set up log file rotation
  #
  remote_file "/etc/logrotate.conf" do
    source "logrotate.conf"
  end
  
  remote_file node[:rs_utils][:logrotate_config] do
    source "logrotate.d.syslog"
  end
  
  # == Fix /var/log/boot.log issue
  #
  file "/var/log/boot.log" 

  # == Tag required to activate logging
  #
  right_link_tag "rs_logging:state=active"
  log "Setting logging active tag"
  
  rs_utils_marker :end

end
