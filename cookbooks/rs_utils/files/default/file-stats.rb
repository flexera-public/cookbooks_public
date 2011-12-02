#! /usr/bin/ruby
# 
# Cookbook Name:: rs_utils
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

#
# Arguments: first the hostname to use to report the stats (instance ID if in EC2)
#            followed by a list of filenames to report

require 'getoptlong'

def usage
  puts("#{$0} -h <hostname> [-i <sample_interval>] <file1> <file2> ...")
  puts("    -h: The hostname of the machine. When using EC2 use the instance ID")
  puts("    -i: The sample interval of the file check (in seconds).  Default: 20 seconds")
  exit
end

opts = GetoptLong.new(
    [ '--hostname', '-h', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--sample-interval', '-i',  GetoptLong::OPTIONAL_ARGUMENT ]
)

# default values
hostname = nil
sample_interval = 20

opts.each do |opt, arg|
  case opt
    when '--hostname'
      hostname = arg
    when '--sample-interval'
      sample_interval = arg.to_i
  end
  arg.inspect
end

# Remaining arguments should be files to monitor
files = ARGV

# ensure we have all the needed params to run, show usage if we don't
usage if !hostname
usage if files.length == 0

loop do
  files.each do |f|
    if File.exist? f
      size = File.size(f)
      now = Time.now
      age = (now - File.mtime(f)).to_i
    else
      size="NaN"
      age="NaN"
    end
    base = File.basename(f, '.*').gsub(/-/, '_')
    print "PUTVAL #{hostname}/file-#{base}/gauge-size interval=#{sample_interval} #{now.to_i}:#{size}\n"
    print "PUTVAL #{hostname}/file-#{base}/gauge-age interval=#{sample_interval} #{now.to_i}:#{age}\n"
  end

  STDOUT.flush
  sleep sample_interval
end
