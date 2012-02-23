#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

swap_size = node[:sys][:swap_size]
swap_file = node[:sys][:swap_file]

def clean_swap(swap_file)

  # Turn off swap on swap_file if turned on
  bash 'deactivate swapfile' do
    flags "-ex"
    only_if { File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? }
    code <<-eof
      swapoff #{swap_file}
    eof
  end

  # Remove swap from /etc/fstab
  mount '/dev/null' do
    action :disable
    device "#{swap_file}"
  end

  # Delete swap_file if it exists
  file "#{swap_file}" do
    only_if {File.exists?(swap_file)}
    backup false
    action :delete
  end

end

def create_swap(swap_file, swap_size)

  # Make sure swapfile directory exists, create swapfile, set it as swap, and turn swap on
  bash 'create swapfile' do
    flags "-ex"
    not_if { File.exists?(swap_file) }
    code <<-eof
      mkdir -p `dirname #{swap_file}`
      dd if=/dev/zero of=#{swap_file} bs=1M count=#{swap_size}
      chmod 600 #{swap_file}
      mkswap #{swap_file}
      swapon #{swap_file}
    eof
  end

  # add swap to /etc/fstab
  mount '/dev/null' do
    action :enable
    device "#{swap_file}"
    fstype 'swap'
  end

end

# Sanitize user data 'swap_size'
if ( swap_size !~ /^\d*[.]?\d+$/ )
  raise "ERROR: invalid swap size."
else
  # Convert swap_size from GB to MB
  swap_size = ((swap_size.to_f)*1024).to_i
end

# Sanitize user data 'swap_file'
if (swap_file !~ /^\/{1}(((\/{1}\.{1})?[a-zA-Z0-9 ]+\/?)+(\.{1}[a-zA-Z0-9]{2,4})?)$/ )
  raise "ERROR: invalid swap file name"
end

# Skip creating swap or disable swap
if (swap_size == 0)
  if ( File.exists?(swap_file) && File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
    clean_swap(swap_file)
  end
  log "swap creation disabled"
else

  # For idempotency, check if selected swapfle is in place, it's correct size, and it's on
  if ( File.exists?(swap_file) && \
       File.stat(swap_file).size/1048576 == swap_size && \
       File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
    log "valid current swap config"
  else

    # Check for remnents of swap
    if ( File.exists?(swap_file) || File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? )
      log "swap remnents detected - cleaning"
      clean_swap(swap_file)
    end

    # Run basic checks on the swap file
    # These must be done in a block so the checks are done during converge
    # The swapfile location may get created during boot (on ephemeral LVM)
    ruby_block 'Check swapfile' do
      block do
        fs_size_threshold_percent = 75

        # Determine if swapfile is too big for fs that holds it
        swap_dir=File.dirname(swap_file)
        FileUtils.mkdir_p(swap_dir) unless swap_dir == "/"
        (fs_total,fs_used) = `df --block-size=1M -P #{swap_dir} |tail -1| awk '{print $2":"$3}'`.chomp.split(":")
        if ( (((fs_used.to_f + swap_size).to_f/fs_total.to_f)*100).to_i > fs_size_threshold_percent )
          raise "ERROR: swap file size too big - would exceed #{fs_size_threshold_percent} percent of filesystem - currently using #{fs_used} out of #{fs_total} wanting to add #{swap_size} in swap"
        end
      end
    end

    # Should now setup swap file
    create_swap(swap_file,swap_size)
  end
end

rs_utils_marker :end
