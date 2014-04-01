#
# Cookbook Name:: sensu_wrapper
# Recipe:: custom_checks
#
# Copyright 2014, Woods Hole Marine Biological Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w[
  check-disk
  mysql-replication-status
].each do |default_plugin|
  cookbook_file "/etc/sensu/plugins/#{default_plugin}.rb" do
    source "plugins/#{default_plugin}.rb"
    mode 0755
  end
end

sensu_check 'check-disk' do
  command 'check-disk.rb'
  handlers ['ponymailer']
  subscribers ['all']
  interval 30
end

# NOTE - Yes, we are currently locked into have a data bag for this to work.
sensu_check 'check-replication-status' do
  config = data_bag_item("reg_master", "config")
  command "/etc/sensu/plugins/mysql-replication-status.rb --host=#{config['host']} --username=#{config['username']} --password=#{config['password']}"
  handlers ['ponymailer']
  subscribers ['sensu_reg_master_lag_checker']
  interval 60
end
