# Cookbook Name:: db_mysql
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

# Ohai returns total in KB.  Set GB so X*gb can be used in conditional
gb=1024*1024*1024
mem = memory[:total]
Chef::Log.info("Auto-tuning MySQL parameters.  Total memory: #{mem}"

set_unless[:db_mysql][:tunable][:thread_cache_size] = "50"
set_unless[:db_mysql][:tunable][:max_connections]     = "800" 
set_unless[:db_mysql][:tunable][:wait_timeout] = "28800"
set_unless[:db_mysql][:tunable][:net_read_timeout]    = "30" 
set_unless[:db_mysql][:tunable][:net_write_timeout]   = "30" 
set_unless[:db_mysql][:tunable][:back_log]            = "128" 
set_unless[:db_mysql][:tunable][:max_heap_table_size] = "32M" 
set_unless[:db_mysql][:tunable][:expire_logs_days] = "10"

set_unless[:db_mysql][:tunable][:innodb_log_file_size]   = "64M"
set_unless[:db_mysql][:tunable][:innodb_log_buffer_size] = "8M"

set_unless[:db_mysql][:tunable][:key_buffer] = "128M"

# <3gb=256, 3<>10=512, 10<>25=1024, 25<>50=2048, >50=4096
if mem < 3*gb
  tune = "256"
else if mem < 10*gb
  tune = "512"
else if mem < 25*gb
  tune = "1024"
else if mem < 50*gb
  tune = "2048"
else 
  tune = "4096"
end
set_unless[:db_mysql][:tunable][:table_cache] = tune

# <3gb=2m, 3<>10=4m, 10<>25=8m, 25<>50=16m, >50=32m
if mem < 3*gb
  tune = "2m"
else if mem < 10*gb
  tune = "4m"
else if mem < 25*gb
  tune = "8m"
else if mem < 50*gb
  tune = "16m"
else 
  tune = "32m"
end
set_unless[:db_mysql][:tunable][:sort_buffer_size] = tune

set_unless[:db_mysql][:tunable][:net_buffer_length] = "16K"     
set_unless[:db_mysql][:tunable][:read_buffer_size] = "1M"
set_unless[:db_mysql][:tunable][:read_rnd_buffer_size] = "4M"

#<3gb=64m, 3<>10=96m, 10<>25=128m, 25<>50=256m, >50=512m
if mem < 3*gb
  tune = "64m"
else if mem < 10*gb
  tune = "96m"
else if mem < 25*gb
  tune = "128m"
else if mem < 50*gb
  tune = "256m"
else 
  tune = "512m"
end
set_unless[:db_mysql][:tunable][:myisam_sort_buffer_size] = tune

set_unless[:db_mysql][:tunable][:query_cache_size] = mem*0.01
set_unless[:db_mysql][:tunable][:innodb_buffer_pool_size] = mem*0.80

#<3gb=50m, 3<>10=200m, 10<>25=300m, 25<>50=400m, >50=500m
if mem < 3*gb
  tune = "50m"
else if mem < 10*gb
  tune = "200m"
else if mem < 25*gb
  tune = "300m"
else if mem < 50*gb
  tune = "400m"
else 
  tune = "500m"
end
set_unless[:db_mysql][:tunable][:innodb_additional_mem_pool_size] = tune

set_unless[:db_mysql][:tunable][:log_slow_queries] = "log_slow_queries = /var/log/mysqlslow.log"
set_unless[:db_mysql][:tunable][:long_query_time] = "long_query_time = 5"
set_unless[:db_mysql][:tunable][:isamchk][:key_buffer] = "128M"
set_unless[:db_mysql][:tunable][:isamchk][:sort_buffer_size] = "128M"
set_unless[:db_mysql][:tunable][:myisamchk][:key_buffer] = "128M"
set_unless[:db_mysql][:tunable][:myisamchk][:sort_buffer_size] = "128M" 

# Override the init timeout value based on memory
#<3gb=600, 3<>10=1200, 10<>25=1800, 25<>50=2400, >50=3000
if mem < 3*gb
  tune = "600"
else if mem < 10*gb
  tune = "1200"
else if mem < 25*gb
  tune = "1800"
else if mem < 50*gb
  tune = "2400"
else 
  tune = "3000"
end
set_unless[:db_mysql][:init_timeout] = tune

if(db_mysql[:server_usage] == :shared)
# Divide some of the values by 1/2
End
