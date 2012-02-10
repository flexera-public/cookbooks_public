#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Installing passenger module
log"INFO: Installing passenger"
bash "Install apache passenger gem" do
  flags "-ex"
  code <<-EOH
/opt/ruby-enterprise/bin/gem install passenger -q --no-rdoc --no-ri
  EOH
  not_if do (File.exists?("/opt/ruby-enterprise/bin/passenger-install-apache2-module")) end
end


bash "Install_apache_passenger_module" do
  flags "-ex"
  code <<-EOH
    /opt/ruby-enterprise/bin/passenger-install-apache2-module --auto
  EOH
  not_if "test -e #{node[:app_passenger][:ruby_gem_base_dir].chomp}/gems/passenger*/ext/apache2/mod_passenger.so"
end

rs_utils_marker :end









