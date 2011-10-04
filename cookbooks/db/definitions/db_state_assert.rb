# Cookbook Name:: db
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
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# == Verify database node state
# Make sure our current_master values are set
# Fail if we think we are a slave, but node state thinks we are a master
# == Params
# name(String):: Assert the type of server we thing we are. Can be :slave, :master, :either
# == Exceptions
# raises Excaption if we are not the server type (:slave or :master) that we expect
#
define :db_state_assert do
  
  ruby_block "check database node state" do
    block do
      type = params[:name]
      master_ip = node[:db][:current_master_ip]
      master_uuid = node[:db][:current_master_uuid]
      raise "No master DB set.  Is this database initialized as a #{type.to_s}?" unless master_ip && master_uuid
      raise "FATAL: this slave thinks its master!" if node[:db][:this_is_master] && type == :slave
      raise "FATAL: this server is not a master!" if (node[:db][:this_is_master] == false) && type == :master
    end
  end

end