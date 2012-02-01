#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

package value_for_platform(
    [ "ubuntu", "debian" ] => { "default" => "libdigest-sha1-perl" },
    [ "centos", "redhat", "suse" ] => { "default" => "perl-Digest-SHA1" }
  )

package value_for_platform(
    [ "ubuntu", "debian" ] => { "default" => "libdigest-hmac-perl" },
    [ "centos", "redhat", "suse" ] => { "default" => "perl-Digest-HMAC" }
  )

directory "/opt/rightscale/dns" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

remote_file "/opt/rightscale/dns/dnscurl.pl" do
  source "dnscurl.pl"
  owner "root"
  group "root"
  mode "0755"
  backup false
end

sys_dns "default" do
  provider "sys_dns_#{node[:sys_dns][:choice]}"
  user node[:sys_dns][:user]
  password node[:sys_dns][:password]
  persist true
  action :nothing
end

rs_utils_marker :end
