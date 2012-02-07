#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

app "Setup Dev Headers" do
  provider "app_passenger"
  packages node[:app_passenger][:packages_install]
  app_root#, :kind_of => String
  app_port#, :kind_of => String
  action :install
end



=begin
#Installing some apache development headers required for rubyEE
node[:app_passenger][:ruby_packages_install].each do |p|
  package p
end

#Installing some apache development headers required for passenger compilation
node[:app_passenger][:packages_install].each do |p|
  package p
end
=end
rs_utils_marker :end
