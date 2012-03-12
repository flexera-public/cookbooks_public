#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#
# Recommended attributes
#
set_unless[:apache][:contact] = "root@localhost"

#
# Optional attributes
#
# Turning off Keepalive to prevent conflicting HAproxy
set_unless[:apache][:keepalive] = "Off" 
# Turn on generation of "full" apache status
set_unless[:apache][:extended_status] = "On"
#  worker = multithreaded
#  prefork = single-threaded (use for php)
set_unless[:apache][:mpm] = "prefork"
# Security: Configuring Server Signature
set_unless[:apache][:serversignature] = "Off "
# DISTRO specific config dir
case platform
when "ubuntu", "debian"
  set[:apache][:config_subdir] = "apache2"
when "centos", "fedora", "suse","redhat"
  set[:apache][:config_subdir] = "httpd"
end

set_unless[:web_apache][:ssl_enable] = false
set_unless[:web_apache][:ssl_certificate] = nil
set_unless[:web_apache][:ssl_certificate_chain] = nil
set_unless[:web_apache][:ssl_key] = nil
set_unless[:web_apache][:ssl_passphrase] = nil

# Used to be called php/code/destination
set[:web_apache][:docroot] = "/home/webapp/#{web_apache[:application_name]}"
set[:web_apache][:server_name] = "localhost"
