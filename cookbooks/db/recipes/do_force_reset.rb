#
# Cookbook Name:: db
#
<<<<<<< HEAD
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Attempt to return the instance to a pristine / newly launched state.
# This is for development and test purpose and should not be used on
# production servers.
# 
rs_utils_marker :begin

raise "Server terminate saftey not off.  Override db/force_safety to run this recipe" unless node[:db][:force_safety] == "off"

log "  Brute force tear down of the setup....."
=======
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Intended for development and testing only
# Most of the time the server will get reset to an original state, but no garuntees
# If you really need a server in a garunteed state then (re)launch a new one.
#
rs_utils_marker :begin

raise "Force reset saftey not off.  Override db/force_reset_safety to run this recipe" unless node[:db][:force_reset_safety] == "off"

log "  Brute force tear down of the setup..... Hope it works :-)"
>>>>>>> sprint30_a29878_bug_fixes
DATA_DIR = node[:db][:data_dir]

log "  Resetting the database..."
db DATA_DIR do
  action :reset
end

log "  Resetting block device..."
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :reset
end

log "  Remove tags..."
bash "remove tags" do
  code <<-EOH
  rs_tag -r 'rs_dbrepl:*'
  EOH
end

ruby_block "Reset db node state" do
  block do
    node[:db][:this_is_master] = false
    node[:db][:current_master_uuid] = nil
    node[:db][:current_master_ip] = nil
  end
end

log "  Resetting database, then starting database..."
db DATA_DIR do
  action [ :reset, :start ]
end

log "  Setting database state to 'uninitialized'..."
db_init_status :reset

log "  Cleaning cron..."
block_device DATA_DIR do
  cron_backup_recipe "#{self.cookbook_name}::do_backup"
  action :backup_schedule_disable
end

rs_utils_marker :end
