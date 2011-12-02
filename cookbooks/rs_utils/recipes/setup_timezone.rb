#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Set the Timezone
#
if node[:rs_utils][:timezone]
  
  rs_utils_marker :begin

  link "/etc/localtime" do
    to "/usr/share/zoneinfo/#{node[:rs_utils][:timezone]}"
  end

  log "Timezone set to #{node[:rs_utils][:timezone]}"

else 

  # If this attribute is not set leave unchanged and use localtime
  log "rs_utils/timezone set to localtime.  Not changing /etc/localtime..."
  
  rs_utils_marker :end
  
end

