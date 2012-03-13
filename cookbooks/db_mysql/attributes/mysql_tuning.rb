#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#
# Adjust values based on a usage factor and create human readable string
#
def value_with_units(value, units, usage_factor)
  raise "Error: value must convert to an integer." unless value.to_i
  raise "Error: units must be k, m, g" unless units =~ /[KMG]/i
  factor = usage_factor.to_f
  raise "Error: usage_factor must be between 1.0 and 0.0. Value used: #{usage_factor}" if factor > 1.0 || factor <= 0.0 
  (value * factor).to_i.to_s + units
end

#
# Set tuning parameters in the my.cnf file.
#

# Shared servers get %50 of the resources allocated to a dedicated server.
set_unless[:db_mysql][:server_usage] = "dedicated"  # or "shared"
usage = 1 # Dedicated server
usage = 0.5 if db_mysql[:server_usage] == "shared"

# Ohai returns total in KB.  Set GB so X*GB can be used in conditional
GB=1024*1024

mem = memory[:total].to_i/1024
Chef::Log.info("Auto-tuning MySQL parameters.  Total memory: #{mem}M")
one_percent_mem = (mem*0.01).to_i
one_percent_str=value_with_units(one_percent_mem,"M",usage)
fifty_percent_mem = (mem*0.50).to_i
fifty_percent_str=value_with_units(fifty_percent_mem,"M",usage)
eighty_percent_mem = (mem*0.80).to_i
eighty_percent_str=value_with_units(eighty_percent_mem,"M",usage)

#
# Fixed parameters, common value for all instance sizes
#
# These parameters may be to large for verry small instance sizes with < 1gb memory.
#
set_unless[:db_mysql][:tunable][:thread_cache_size]                 = (50 * usage).to_i
set_unless[:db_mysql][:tunable][:max_connections]                   = (800 * usage).to_i
set_unless[:db_mysql][:tunable][:wait_timeout]                      = (28800 * usage).to_i
set_unless[:db_mysql][:tunable][:net_read_timeout]                  = (30 * usage).to_i
set_unless[:db_mysql][:tunable][:net_write_timeout]                 = (30 * usage).to_i
set_unless[:db_mysql][:tunable][:back_log]                          = (128 * usage).to_i
set_unless[:db_mysql][:tunable][:max_heap_table_size]               = value_with_units(32,"M",usage)
set_unless[:db_mysql][:tunable][:net_buffer_length]                 = value_with_units(16,"K",usage)
set_unless[:db_mysql][:tunable][:read_buffer_size]                  = value_with_units(1,"M",usage)
set_unless[:db_mysql][:tunable][:read_rnd_buffer_size]              = value_with_units(4,"M",usage)
set_unless[:db_mysql][:tunable][:log_slow_queries]                  = "log_slow_queries = /var/log/mysqlslow.log"
set_unless[:db_mysql][:tunable][:long_query_time]                   = "long_query_time = 5"
set_unless[:db_mysql][:tunable][:expire_logs_days]                  = 2

#
# Adjust based on memory range.
#
# The memory ranges used are < 1GB, 1GB - 3GB, 3GB - 10GB, 10GB - 25GB, 25GB - 50GB, > 50GB.
if mem < 1*GB
  #
  # Override buffer sizes for really small servers
  #
  set_unless[:db_mysql][:tunable][:key_buffer]                      = value_with_units(16,"M",usage)
  set_unless[:db_mysql][:tunable][:isamchk][:key_buffer]            = value_with_units(20,"M",usage)
  set_unless[:db_mysql][:tunable][:isamchk][:sort_buffer_size]      = value_with_units(20,"M",usage)
  set_unless[:db_mysql][:tunable][:myisamchk][:key_buffer]          = value_with_units(20,"M",usage)
  set_unless[:db_mysql][:tunable][:myisamchk][:sort_buffer_size]    = value_with_units(20,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_log_file_size]            = value_with_units(4,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_log_buffer_size]          = value_with_units(16,"M",usage)
else
  set_unless[:db_mysql][:tunable][:key_buffer]                      = value_with_units(128,"M",usage)
  set_unless[:db_mysql][:tunable][:isamchk][:key_buffer]            = value_with_units(128,"M",usage)
  set_unless[:db_mysql][:tunable][:isamchk][:sort_buffer_size]      = value_with_units(128,"M",usage)
  set_unless[:db_mysql][:tunable][:myisamchk][:key_buffer]          = value_with_units(128,"M",usage)
  set_unless[:db_mysql][:tunable][:myisamchk][:sort_buffer_size]    = value_with_units(128,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_log_file_size]            = value_with_units(64,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_log_buffer_size]          = value_with_units(8,"M",usage)
end

if mem < 3*GB
  set_unless[:db_mysql][:tunable][:table_cache]                     = (257 * usage).to_i
  set_unless[:db_mysql][:tunable][:sort_buffer_size]                = value_with_units(2,"M",usage)
  set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size]         = value_with_units(64,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_additional_mem_pool_size] = value_with_units(50,"M",usage)
  set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size]         = value_with_units(96,"M",usage)
  set_unless[:db_mysql][:init_timeout]                              = (600 * usage).to_i
elsif mem < 10*GB
  set_unless[:db_mysql][:tunable][:table_cache]                     = (512 * usage).to_i
  set_unless[:db_mysql][:tunable][:sort_buffer_size]                = value_with_units(4,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_additional_mem_pool_size] = value_with_units(200,"M",usage)
  set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size]         = value_with_units(96,"M",usage)
  set_unless[:db_mysql][:init_timeout]                              = (1200 * usage).to_i
elsif mem < 25*GB
  set_unless[:db_mysql][:tunable][:table_cache]                     = (1024 * usage).to_i
  set_unless[:db_mysql][:tunable][:sort_buffer_size]                = value_with_units(8,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_additional_mem_pool_size] = value_with_units(300,"M",usage)
  set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size]         = value_with_units(128,"M",usage)
  set_unless[:db_mysql][:init_timeout]                              = (1800 * usage).to_i
elsif mem < 50*GB
  set_unless[:db_mysql][:tunable][:table_cache]                     = (2048 * usage).to_i
  set_unless[:db_mysql][:tunable][:sort_buffer_size]                = value_with_units(16,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_additional_mem_pool_size] = value_with_units(400,"M",usage)
  set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size]         = value_with_units(256,"M",usage)
  set_unless[:db_mysql][:init_timeout]                              = (2400 * usage).to_i
else 
  set_unless[:db_mysql][:tunable][:table_cache]                     = (4096 * usage).to_i
  set_unless[:db_mysql][:tunable][:sort_buffer_size]                = value_with_units(32,"M",usage)
  set_unless[:db_mysql][:tunable][:innodb_additional_mem_pool_size] = value_with_units(500,"M",usage)
  set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size]         = value_with_units(512,"M",usage)
  set_unless[:db_mysql][:init_timeout]                              = (3000 * usage).to_i
end

#
# Calculate as a percentage of memory
#
Chef::Log.info("Setting query_cache_size to: #{one_percent_str}")
set_unless[:db_mysql][:tunable][:query_cache_size]                  = one_percent_str
Chef::Log.info("Setting query_cache_size to: #{eighty_percent_str}")
set_unless[:db_mysql][:tunable][:innodb_buffer_pool_size]           = eighty_percent_str
#set_unless[:db_mysql][:tunable][:innodb_buffer_pool_size]           = fifty_percent_str

