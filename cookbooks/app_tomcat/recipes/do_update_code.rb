# Cookbook Name:: app_tomcat
# Recipe:: do_update_code
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

# Check that we have the required attributes set
raise "You must provide a destination for your application code." if ("#{node[:tomcat][:docroot]}" == "")

node[:tomcat][:docroot] = "/srv/tomcat6/webapps/#{node[:tomcat][:application_name]}"

  directory "/srv/tomcat6/webapps/" do
    recursive true
  end

service "tomcat6" do
  action :nothing
end


# Downloading project repo
repo "default" do
  destination node[:tomcat][:docroot]
  action node[:tomcat][:code][:perform_action]
  app_user node[:tomcat][:app_user]
end


# Set ROOT war and code ownership
bash "set_root_war_and_chown_home" do
  flags "-ex"
  code <<-EOH
    cd #{node[:tomcat][:docroot]}
    if [ ! -z "#{node[:tomcat][:code][:root_war]}" -a -e "#{node[:tomcat][:docroot]}/#{node[:tomcat][:code][:root_war]}" ] ; then
      mv #{node[:tomcat][:docroot]}/#{node[:tomcat][:code][:root_war]} #{node[:tomcat][:docroot]}/ROOT.war
    fi
    chown -R #{node[:tomcat][:app_user]}:#{node[:tomcat][:app_user]} #{node[:tomcat][:docroot]}
    sleep 5
    service tomcat6 restart
  EOH
end

node[:delete_docroot_executed] = true

rs_utils_marker :end
