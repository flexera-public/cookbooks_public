#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Installing memcached package..."


case node[:platform]
  when "ubuntu", "debian"
    #####
    log "  not debian... skipping..."

  when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
     # config_file="/etc/sysconfig/memcached"
     # iptables_rules="/etc/sysconfig/iptables"
     #
     # if [ -f "$config_file" ]; then
     # echo "Memcache already installed, skipping..."
     # exit 0
     # fi
     #
     # yum install -y memcached
      package "memcached" do
        action :install
      end

     # cp -f "$config_file" "$config_file.old"
     # touch "$config_file"
     #
     # if [ -n "$OPT_MEMCACHED_PORT" ]; then
     # echo "PORT=\"$OPT_MEMCACHED_PORT\"" >> $config_file
     # else
     #   #to be used by the iptables rule
     #   OPT_MEMCACHED_PORT=11211
     #   fi
     #   if [ -n "$OPT_MEMCACHED_MEMORY" ]; then
     #   #remove the %
     #   OPT_MEMCACHED_MEMORY=${OPT_MEMCACHED_MEMORY/\%/}
	   #   if ! egrep -q "^[0-9]+$"<<<"$OPT_MEMCACHED_MEMORY"; then
	   #     echo 'OPT_MEMCACHED_MEMORY must be a percentage. Ex: 70%'
	   #     exit 1
	   #   else
  	 #   OPT_MEMCACHED_MEMORY=`grep 'MemTotal' /proc/meminfo | awk '{print $2 * '$OPT_MEMCACHED_MEMORY' / 102400}' | cut -f1 -d .`
     #   echo "CACHESIZE=\"$OPT_MEMCACHED_MEMORY\"" >> $config_file
     #   fi
     #   fi
     #
     #   if [ -n "$OPT_MEMCACHED_OPTIONS" ]; then
     #   extra_opts="$extra_opts $OPT_MEMCACHED_OPTIONS"
     #   fi
     #
     #  echo "OPTIONS=\"$extra_opts\"" >> $config_file
     #  chkconfig memcached on
     #  chkconfig --add memcached
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end




log "  memcached package successfully installed!"

rs_utils_marker :end