#
# Cookbook Name:: app
# Resource:: app::default
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# Install packages required for application server setup
actions :install
  # Set of installed packages
  attribute :packages, :kind_of => Array

# Set up the application vhost on specified port
# Action designed to setup APP LWRP with common parameters required for apache vhost file
actions :setup_vhost
  # Application root
  attribute :root, :kind_of => String
  # Application port
  attribute :port, :kind_of => Integer


# Runs application server start sequence
actions :start

# Runs application server stop sequence
actions :stop

# Runs application server restart sequence
actions :restart

# Updates application source files from the remote repository
# Action designed to setup APP LWRP with common parameters required for source code update/download
actions :code_update
  #Destination for source code download
  attribute :destination, :kind_of => String


# Set up the database connection file
# Action designed to setup APP LWRP with common parameters required for database configuration file creation
actions :setup_db_connection
  # Name of the required database
  attribute :database_name, :kind_of => String
  # Database user
  attribute :database_user, :kind_of => String
  # Database password
  attribute :database_password, :kind_of => String
  # Database server fqdn
  attribute :database_sever_fqdn, :kind_of => String

# Action designed to setup APP LWRP with common parameters required for install and configuration of required monitoring software
actions :setup_monitoring
