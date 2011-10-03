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

