#
# Cookbook Name:: repo
# Resource:: repo
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

actions :install
  attribute :packages, :kind_of => Array  #set of installed packages

########################
actions :setup_apache_vhost
 attribute :app_root, :kind_of => String
 attribute :app_port, :kind_of => String

########################
actions :start
actions :stop
actions :restart
 attribute :service, :kind_of => String


actions :code_update
  attribute :destination, :kind_of => String
  attribute :pull_type, :kind_of => String


actions :setup_db_connection
  attribute :db_host, :kind_of => String
  attribute :db_port, :kind_of => String
  attribute :db_provider, :kind_of => String
  attribute :db_user, :kind_of => String
  attribute :db_password, :kind_of => String

actions :setup_monitoring

##########################
