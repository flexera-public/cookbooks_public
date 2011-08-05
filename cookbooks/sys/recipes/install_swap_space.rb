#
# Cookbook Name:: sys
# Recipe:: install_swap_space
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
# Cookbook Name:: app_tomcat
# Recipe:: default

swap_size = node[:sys][:swap_size]
swap_file = "/swapfile"

# sanitize user data
if (swap_size !~ /^[0-9][\d\.]*$/ )
  log "invalid swap size '#{swap_size}' - raising error"
  raise "ERROR: invalid swap size."
else
  log "valid swap size '#{swap_size}'"
  # convert swap_size from GB to MB
  swap_size = ((swap_size.to_f)*1024).to_i
end

# check if swap is disabled
if (swap_size == 0)
  log "swap size = 0 - disabling swap"
else
  script 'create swapfile' do
    not_if {File.exists?(swap_file)}
    interpreter 'bash'
    code <<-eof
      dd if=/dev/zero of=#{swap_file} bs=1M count=#{swap_size}
      chmod 600 #{swap_file}
      mkswap #{swap_file}
      swapon #{swap_file}
    eof
  end

  # append swap to /etc/fstab if not already there
  append_to_fstab = true
  fstab_contents = File.open('/etc/fstab') { |f| f.read }
  fstab_contents.each_line do |line| 
    if ( line.strip =~ /^#{swap_file}/ )
      append_to_fstab = false
      break
    end
  end
    
  if (append_to_fstab)
    fstab_contents << "\n#{swap_file}  swap      swap    defaults        0 0\n"
    file "/etc/fstab" do
      content fstab_contents
      owner "root"
      group "root"
      mode "0644"
      action :create
    end
  else
    log "#{swap_file} fstab entry already exists - skipping editing fstab"
  end

end
