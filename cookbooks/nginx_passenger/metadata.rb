maintainer        "RightScale Inc."
maintainer_email  "support@rightscale.com"
license           "Apache 2.0"
description       "Installs nginx passenger"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.9.0"

recipe "nginx_passenger::default", "Installs nginx-passenger"

%w{ centos redhat ubuntu debian }.each do |os|
  supports os
end
