#
# Cookbook Name:: sensu_wrapper
# Recipe:: server
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

dashboard_defaults = custom_defaults['sensu'] || {}
node.default['sensu']['dashboard']['user'] = dashboard_defaults['dashboard_user']
node.default['sensu']['dashboard']['password'] = dashboard_defaults['dashboard_password']

monitor_defaults = custom_defaults['monitor'] || {}
node.default['monitor']['email_recipients'] = monitor_defaults['email_recipients']
node.default['monitor']['from_email'] = monitor_defaults['from_email'] || 'monitor@example.com'
node.default['monitor']['from_name'] = monitor_defaults['from_name'] || 'Monitor'
node.default['monitor']['from_host'] = monitor_defaults['from_host'] || 'localhost'
node.default['monitor']['graphite_address'] = monitor_defaults['graphite_address'] || 'localhost'
node.default['monitor']['graphite_port'] = monitor_defaults['graphite_port'] || 2003
node.default['graphite']['carbon']['line_receiver_port'] = node.default['monitor']['graphite_port']

postfix_defaults = custom_defaults['postfix'] || {}
node.default['postfix']['main']['mydomain'] = postfix_defaults['mydomain'] || 'example.com'
node.default['postfix']['main']['myorigin'] = postfix_defaults['myorigin'] || 'example.com'
node.default['postfix']['main']['smtp_use_tls'] = postfix_defaults['smtp_use_tls'] || 'no'
node.default['postfix']['main']['smtpd_use_tls'] = postfix_defaults['smtpd_use_tls'] || 'no'

include_recipe 'postfix::server'
include_recipe 'monitor::master'
graphite_host = search(:node, 'recipes:graphite\:\:default')
unless (graphite_host.respond_to?(:empty?) ? graphite_host.empty? : !graphite_host)
  # this recipe requires that a node exists with recipe graphite (like eol-cookbook::graphite_server)
  include_recipe 'monitor::_graphite_handler'
end
include_recipe 'sensu_wrapper::_ponymailer_handler'
include_recipe 'sensu_wrapper::_check_disk'
include_recipe 'sensu_wrapper::_hipchat_handler'
