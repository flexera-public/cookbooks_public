# Cookbook Name:: app_rails
# Recipe:: setup_db_config
#
# Copyright (c) 2009 RightScale Inc
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

ruby "setup database configuration" do

  code <<-EOH
    require 'yaml'
    require 'fileutils'
    
    rails_dir = "#{@node[:rails][:code][:destination]}"
    
    db_conf = "\#{rails_dir}/config/database.yml"
    rails_env = "#{@node[:rails][:env]}"
    
    db_app_user = "#{@node[:rails][:db_app_user]}"=="" ? nil : "#{@node[:rails][:db_app_user]}"	     
    db_app_password = "#{@node[:rails][:db_app_passwd]}" =="" ? nil : "#{@node[:rails][:db_app_passwd]}"      
    db_schema_name = "#{@node[:rails][:db_schema_name]}"=="" ? nil : "#{@node[:rails][:db_schema_name]}"
    db_dns_name = "#{@node[:rails][:db_dns_name]}"=="" ? nil : "#{@node[:rails][:db_dns_name]}"
    db_adapter = "#{@node[:rails][:db_adapter]}"=="" ? nil : "#{@node[:rails][:db_adapter]}"
    
    # Create the empty file in case it doesn't exist
    if ! FileTest.exists?(db_conf)
      puts "No config file exists...creating one."
      FileUtils.mkdir_p "\#{rails_dir}/config"
      empty = { rails_env => {"database"=>nil,"username"=>nil,"password"=>nil,"host"=>nil, "adapter"=>"mysql"} }

      File.open(db_conf, "w") do |f|
            f << empty.to_yaml
      end
    else
      puts "Config file already exists...modifying it."
    end

    conf = YAML.load_file(db_conf)
    #Create the section if it doesn't exist
    conf[rails_env]={} if conf[rails_env] == nil
    section_conf = conf[rails_env]
  
    section_conf['database'] = db_schema_name if db_schema_name
    section_conf['username'] = db_app_user if db_app_user
    section_conf['password'] = db_app_password if db_app_password
    section_conf['host'] = db_dns_name if db_dns_name
    section_conf['adapter'] = db_adapter if db_adapter

    #Write the changed configuration
    File.open(db_conf, "w") do |f|
            f << conf.to_yaml
    end
  EOH
end
