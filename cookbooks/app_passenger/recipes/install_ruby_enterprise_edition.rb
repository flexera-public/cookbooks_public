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

cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
  source "ruby-enterprise_x86_64.tar.gz"
  mode "0644"
  only_if do node[:kernel][:machine].include? "x86_64" end
end

cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
  source "ruby-enterprise_i686.tar.gz"
  mode "0644"
  only_if do node[:kernel][:machine].include? "i686" end
end

bash "install_ruby_EE" do
  code <<-EOH
    tar xzf /tmp/ruby-enterprise-installed.tar.gz -C /opt/
  EOH
  only_if do File.exists?("/tmp/ruby-enterprise-installed.tar.gz")  end
end

rs_utils_marker :end