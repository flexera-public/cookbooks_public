#
# Cookbook Name:: sys
# Recipe:: setup_swap
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

rs_utils_marker :begin

swap_size = node[:sys][:swap_size]
swap_file = node[:sys][:swap_file]

fs_size_threshold_percent = 75

def clean_swap(swap_file)

  # turn off swap on swap_file if turned on
  if ( File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
    script 'deactivate swapfile' do
      interpreter 'bash'
      code <<-eof
        swapoff #{swap_file}
      eof
    end
  end

  # remove swap from /etc/fstab
  if ( File.open('/etc/fstab').grep(/^\s*#{swap_file}\b/).any? )
    new_fstab_contents = ""
    fstab_contents = File.open('/etc/fstab') { |f| f.read }
    fstab_contents.each_line do |line| 
      if ( line.strip =~ /^#{swap_file}\b/ )
        # skipping
      else
        new_fstab_contents << line
      end
    end
    file "/etc/fstab" do
      content new_fstab_contents
      owner "root"
      group "root"
      mode "0644"
      action :create
    end
  end

  # delete swap_file if it exists
  if ( File.exists?(swap_file) )
    file "#{swap_file}" do
      backup false
      action :delete
    end
  end

end

def create_swap(swap_file, swap_size)

  # create swapfile, set it as swap, and turn swap on
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
  if ( File.open('/etc/fstab').grep(/^\s*#{swap_file}\b/).any? )
    log "#{swapfile} already in /etc/fstab"
  else
    fstab_contents = File.open('/etc/fstab') { |f| f.read }
    fstab_contents << "#{swap_file}  swap      swap    defaults        0 0\n"
    file "/etc/fstab" do
      content fstab_contents
      owner "root"
      group "root"
      mode "0644"
      action :create
    end
  end
end

# sanitize user data 'swap_size'
if ( swap_size !~ /^\d*[.]?\d+$/ )
  log "invalid swap size '#{swap_size}' - raising error"
  raise "ERROR: invalid swap size."
else
  # convert swap_size from GB to MB
  swap_size = ((swap_size.to_f)*1024).to_i
end

# sanitize user data 'swap_file'
if (swap_file !~ /^\/{1}(((\/{1}\.{1})?[a-zA-Z0-9 ]+\/?)+(\.{1}[a-zA-Z0-9]{2,4})?)$/ )
  log "invalid swap file name - raising error"
  raise "ERROR: invalid swap file name"
end

# skip creating swap or disable swap
if (swap_size == 0)
  if ( File.exists?(swap_file) && File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
    clean_swap(swap_file)
  else
    log "swap creation disabled"
  end
else

  # for idempotency, check if selected swapfle is in place, correct size, and on
  if ( File.exists?(swap_file) && \
       File.stat(swap_file).size/1048576 == swap_size && \
       File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
    log "valid current swap config"
  else
    # check for remnents of swap
    if ( File.exists?(swap_file) || File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
      log "swap remnents detected - cleaning"
      clean_swap(swap_file)
    end

    # determine if swapfile is too big for fs that holds it
    (fs_total,fs_used) = `df --block-size=1M -P #{File.dirname(swap_file)} |tail -1| awk '{print $2":"$3}'`.split(":")
    if ( (((fs_used.to_f + swap_size).to_f/fs_total.to_f)*100).to_i >= fs_size_threshold_percent )
      log "swap file size would exceed filesystem threshold of #{fs_size_threshold_percent} percent - raising error"
      raise "ERROR: swap file size too big - would exceed #{fs_size_threshold_percent} percent of filesystem"
    end

    # should now setup swap file
    create_swap(swap_file,swap_size)
  end
end

rs_utils_marker :end
