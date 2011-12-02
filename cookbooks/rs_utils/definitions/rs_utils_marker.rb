#
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :rs_utils_marker do

  recipe_name = "#{self.cookbook_name}" + "::" + "#{self.recipe_name}"

  location = params[:name] ? params[:name] : "start"

  # translate symbols to strings ie :begin = "begin"
  location = location.to_s

  # detect if used 'begin' instead of 'start' or 'stop' instead of 'end'
  if ( location =~ /^begin$/ ) then location = "start" end
  if ( location =~ /^stop$/ ) then location = "end" end

  if location =~ /^start|end$/
    log "======== #{recipe_name} : #{location.upcase} ========"
  else
    log "unknown marker"
  end

end

