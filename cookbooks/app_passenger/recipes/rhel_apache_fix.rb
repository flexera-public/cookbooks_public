# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


#Recipe created to fix some issues in Centos / RHEL images


#Fixing  centos root certificate authority issues
bash "fix certs" do
  code <<-EOH
    cp /etc/pki/tls/certs/ca-bundle.crt /root/
    curl http://curl.haxx.se/ca/cacert.pem -o /etc/pki/tls/certs/ca-bundle.crt
  EOH
  only_if do (node[:platform]=="redhat" || node[:platform]=="centos") end
end

# removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  backup false
  only_if do (node[:platform]=="redhat" || node[:platform]=="centos") end
end


#installing packages required for mysql gem installation until db recipe on rhel will be fixed
    node[:app_passenger][:mysql_packages_install]= ["mysql", "mysql-devel","mysqlclient15", "mysqlclient15-devel"]
   #installing packages required for  compilation
case node[:platform]
  when "redhat","redhatenterpriseserver", "centos"

    node[:app_passenger][:mysql_packages_install].each do |p|
      package p
    end

  when "ubuntu","debian"
    log "Nothing to do!"
end
rs_utils_marker :end