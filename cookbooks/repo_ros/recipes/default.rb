#
# Cookbook Name:: repo_ros
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

raise "  ROS gem missing, please add rs_utils::install_tools or rs_tools::default recipes to runlist." unless File.exists?("/opt/rightscale/sandbox/bin/ros_util")

rs_utils_marker :end