#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Required attributes
#



# Recommended attributes
#



# Optional attributes
#



# Platform specific attributes
#


# System tuning parameters
# Set the mysql and root users max open files to a really large number.
# 1/3 of the overall system file max should be large enough.  The percentage can be
# adjusted if necessary.
set_unless[:memcached][:test_attribute] = 'now'
