case platform 
when "ubuntu","debian"
  default[:sys_ntp][:service] = "ntp"
when "redhat","centos","fedora"
  default[:sys_ntp][:service] = "ntpd"
end

default[:sys_ntp][:is_server] = false
default[:sys_ntp][:servers] = "time.rightscale.com, ec2-us-east.time.rightscale.com, ec2-us-west.time.rightscale.com"
