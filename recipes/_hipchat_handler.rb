#
# Cookbook Name:: sensu_wrapper
# Recipe:: _hipchat_handler
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

custom_defaults = data_bag_item('custom_defaults', 'config') rescue {}
monitor_config = custom_defaults['monitor']

if monitor_config && monitor_config['hipchat_api_key']
  sensu_gem 'hipchat'

  cookbook_file '/etc/sensu/handlers/hipchat.rb' do
    source 'handlers/hipchat.rb'
    mode 0755
  end

  sensu_snippet 'hipchat' do
    content(:apikey => monitor_config['hipchat_api_key'], :room => monitor_config['hipchat_room'])
  end

  sensu_handler 'hipchat' do
    type 'pipe'
    command 'hipchat.rb'
  end
end
