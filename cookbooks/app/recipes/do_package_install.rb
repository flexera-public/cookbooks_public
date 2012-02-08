#
# Cookbook Name::app
# Recipe::do_package_install
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

app "default" do
    action :install
end

rs_utils_marker :end
