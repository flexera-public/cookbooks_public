# Copyright (c) 2011 RightScale, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

actions :update, :update_request


attribute :port, :kind_of => Integer # Can also be passed as resource name
attribute :protocol, :equal_to => ["tcp", "udp", "all" ], :default => "tcp"
attribute :enable, :equal_to => [ true, false ], :default => true

attribute :ip_addr, :kind_of => String, :default => "any"
attribute :machine_tag, :kind_of => String, :regex => /^([^:]+):(.+)=.+/
attribute :collection, :kind_of => String, :default => "sys_firewall"


# Defines a default action
def initialize(*args)
  super
  @action = :update  
end