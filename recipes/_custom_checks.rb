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
  check-disk.rb
].each do |default_plugin|
  cookbook_file "/etc/sensu/plugins/#{default_plugin}" do
    source "plugins/#{default_plugin}"
    mode 0755
  end
end

sensu_check 'check-disk' do
  command 'check-disk.rb'
  handlers ['ponymailer']
  subscribers ['all']
  interval 30
end

sensu_check 'check-replication-status' do
  # NOTE - the user/pass here (which I realize is in the open) ONLY has access to this ONE command. Later we can make this more secure by using a data_bag
  # to store the credentials, but for now, there's very little security risk anyway:
  # TODO - That said, the host really should be from a data_bag.  :\
  command '/etc/sensu/plugins/mysql-replication-status.rb --host=eol-reg-mast1.core.cli.mbl.edu --username=sensu --password=1statusOnly'
  handlers ['ponymailer']
  subscribers ['sensu_reg_master_lag_checker']
  interval 60
end
