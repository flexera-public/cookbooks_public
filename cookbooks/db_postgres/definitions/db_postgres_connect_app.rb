#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_postgres_connect_app, :template => "db_connection_example.erb", :cookbook => "db_postgres", :database => nil do
  
  template params[:name] do
    source params[:template]
    cookbook params[:cookbook]
    mode 0440
    owner params[:owner]
    group params[:group]
    backup false
    variables(
      :user => node[:db][:application][:user],
      :password => node[:db][:application][:password],
      :fqdn => node[:db][:dns][:master][:fqdn],
      :socket => node[:db_postgres][:socket],
      :database => params[:database]
    )
  end

end
