#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

package "debian-helper-scripts" if node[:platform] == 'ubuntu' && node[:lsb][:codename] == 'hardy'

include_recipe "rs_utils::setup_server_tags"
include_recipe "rs_utils::setup_timezone"
include_recipe "rs_utils::setup_logging"
include_recipe "rs_utils::setup_mail"
include_recipe "rs_utils::setup_monitoring"

rs_utils_marker :end
