case platform 
when "ubuntu","debian"
  default[:ntp][:service] = "ntp"
when "redhat","centos","fedora"
  default[:ntp][:service] = "ntpd"
end

default[:ntp][:is_server] = false
default[:ntp][:servers] = ["time.rightscale.com", "ec2-us-east.time.rightscale.com", "ec2-us-west.time.rightscale.com" ]
