#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
  source "ruby-enterprise_x86_64.tar.gz"
  mode "0644"
  only_if do node[:kernel][:machine].include? "x86_64" end
end

cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
  source "ruby-enterprise_i686.tar.gz"
  mode "0644"
  only_if do node[:kernel][:machine].include? "i686" end
end

bash "install_ruby_EE" do
  flags "-ex"
  code <<-EOH
    tar xzf /tmp/ruby-enterprise-installed.tar.gz -C /opt/
  EOH
  only_if do File.exists?("/tmp/ruby-enterprise-installed.tar.gz") end
end

rs_utils_marker :end
