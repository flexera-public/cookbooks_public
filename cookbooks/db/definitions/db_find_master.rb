#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Used to find master db
# When a slave database starts, it needs to determine which database it should use as
# master.  If there is only one DB tagged as master, it will be chosen. Lineage is used to
# restore the database from a backup created by the master.  Master DBs can contain it's lineage
# in it's "rs_dbrepl:master_active" tag. This definition uses this logic to detemine what
# database should be master for the slave running it.
# == Params
# == Exceptions


define :db_find_master do

  r = rs_utils_server_collection "master_servers" do
    tags 'rs_dbrepl:master_instance_uuid'
    secondary_tags ['rs_dbrepl:master_active', 'server:private_ip_0']
    action :nothing
  end
  r.run_action(:load)

  # Finds the master matching lineage and sets the node attribs for
  #   node[:db][:current_master_uuid]
  #   node[:db][:current_master_ip]
  #   node[:db][:this_is_master]
  #   node[:db][:current_master_ec2_id] - for 11H1 migration
  r = ruby_block "find current master" do
    block do

      # Declare vars needed after 'each do' loop below
      collect = {}
      lineage = ""
      # Using reverse order to end with first found master if no DB tagged with lineage.
      node[:server_collection]["master_servers"].reverse_each do |id, tags|
        master_active_tag = tags.select { |s| s =~ /rs_dbrepl:master_active/ }

        active,lineage = master_active_tag[0].split('-',2)

        my_uuid = tags.detect { |u| u =~ /rs_dbrepl:master_instance_uuid/ }
        my_ip_0 = tags.detect { |i| i =~ /server:private_ip_0/ }
        # following used for detecting 11H1 DB servers
        ec2_instance_id = tags.detect { |each_ec2_instance_id| each_ec2_instance_id =~ /ec2:instance_id/ }
        most_recent = active.sort.last
        collect[most_recent] = my_uuid, my_ip_0, ec2_instance_id

        # If this master has the right lineage, break, else continue checking.
        if ( lineage && lineage == node[:db][:backup][:lineage] )
          Chef::Log.info "#{lineage} : Lineage match found"
          break
        else
          Chef::Log.info "#{lineage} : Lineage mismatch - checking next"
        end

      end

      # If lineage was not part of the master_active_tag tag
      # use old method of using first (or only)  found master
      unless ( lineage && lineage == node[:db][:backup][:lineage] )
        Chef::Log.info "Lineage not found in tags, defaulting to first discovered master"
      end

      most_recent_timestamp = collect.keys.sort.last
      current_master_uuid, current_master_ip, current_master_ec2_id = collect[most_recent_timestamp]
      if current_master_uuid =~ /#{node[:rightscale][:instance_uuid]}/
        Chef::Log.info "THIS instance is the current master"
        node[:db][:this_is_master] = true
      else
        node[:db][:this_is_master] = false
      end
      if current_master_uuid
        node[:db][:current_master_uuid] = current_master_uuid.split(/=/, 2).last.chomp
      else
        node[:db][:current_master_uuid] = nil
        Chef::Log.info "No current master db found"
      end
      if current_master_ip
        node[:db][:current_master_ip] = current_master_ip.split(/=/, 2).last.chomp
      else
        node[:db][:current_master_ip] = nil
        Chef::Log.info "No current master ip found"
      end

      # following used for detecting 11H1 DB servers
      if current_master_ec2_id
        node[:db][:current_master_ec2_id] = current_master_ec2_id.split(/=/, 2).last.chomp
        Chef::Log.info "Detected #{current_master_ec2_id} - 11H1 migration"
      else
        node[:db][:current_master_ec2_id] = nil
      end

      Chef::Log.info "found current master: #{node[:db][:current_master_uuid]} ip: #{node[:db][:current_master_ip]} active at #{most_recent_timestamp}" if current_master_uuid && current_master_ip
    end
  end
  r.run_action(:create)

  raise "No master DB found" unless node[:db][:current_master_ip] && node[:db][:current_master_uuid]

end
