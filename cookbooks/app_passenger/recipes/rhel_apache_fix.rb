# Cookbook Name:: app_passenger
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
#
rs_utils_marker :begin

###
#Recipe created to fix some issues in Centos / RHEL images
###

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



rs_utils_marker :end