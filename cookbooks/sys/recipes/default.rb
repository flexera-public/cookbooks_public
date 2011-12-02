#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin
include_recipe "sys::do_reconverge_list_enable"
rs_utils_marker :end
