#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

actions :load

attribute :tags, :kind_of => [String, Array]
attribute :secondary_tags, :kind_of => [String, Array]
attribute :agent_ids, :kind_of => [String, Array]
attribute :timeout, :default => 60, :kind_of => Integer
attribute :empty_ok, :default => true, :equal_to => [true, false]

# Defines a default action
def initialize(*args)
  super
  @action = :load
end
