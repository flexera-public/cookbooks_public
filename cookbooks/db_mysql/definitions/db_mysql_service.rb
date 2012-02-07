#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_setup_service do

  service "mysql" do
    service_name = node[:db_mysql][:service_name]
    supports :status => true, :restart => true, :reload => true
    case :platform
    when "ubuntu"
      provider Chef::Provider::Service::Upstart
    end
    action :nothing
  end
end


