#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set a default provider for app to connect with lb cookbook attach/detach
# for application servers without their own provider.
set_unless[:app][:provider] = "app"
# By default listen on port 8000
set_unless[:app][:port] = "8000"
# By default listen on the first private IP
set_unless[:app][:ip] = node[:cloud][:private_ips][0]
