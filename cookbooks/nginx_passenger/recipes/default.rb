#
# Cookbook Name:: nginx_passenger
# Recipe:: default
#

case node[:platform]
when "ubuntu","debian"
	bash "apt-install" do 
		code<<-EOF
		echo "deb http://apt.brightbox.net hardy main" >> /etc/apt/sources.list.d/passenger
		apt-get update
		apt-get install nginx-brightbox
		EOF
	end
when "centos","rhel"
	bash "yum install" do 
		code<<-EOF
		rpm -Uvh http://passenger.stealthymonkeys.com/rhel/5/passenger-release.noarch.rpm
		yum install -y nginx-passenger
		EOF
	end
end
