#
# Cookbook Name:: nginx_passenger
# Recipe:: default
#

case node[:platform]
when "ubuntu","debian"
	bash "apt-install" do
		user "root"
  	cwd "/tmp"
		code <<-EOF
		echo "deb http://apt.brightbox.net hardy main" >> /etc/apt/sources.list.d/passenger
		apt-get update
		apt-get install nginx-brightbox
		EOF
	end
when "centos","rhel"
	bash "yuminstall" do
		user "root"
    cwd "/tmp"
		code <<-EOF
		rpm -Uvh http://passenger.stealthymonkeys.com/rhel/5/passenger-release.noarch.rpm
		yum install -y nginx-passenger
		EOF
	end
end
