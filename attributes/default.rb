#
# Cookbook Name:: backup
# Attributes:: default
#
# Copyright 2011, Cramer Development, Inc.
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

default['backup']['path']         = '/var/backups' # LEGACY
default['backup']['config_path']  = '/etc/backup'
default['backup']['log_path']     = '/var/log'
default['backup']['addl_flags']   = ''
default['backup']['model_path']   = "#{node['backup']['config_path']}/models"
default['backup']['mount_options'] = []

default['backup']['user']         = 'root'
default['backup']['group']        = 'root'

default['backup']['dependencies'] = []
default['backup']['version'] = '4.4.0'
default['backup']['version_from_git?'] = false
default['backup']['install_gem?'] = false
default['backup']['git_repo'] = nil
default['backup']['upgrade?'] = false
default['backup']['rvm_ruby'] = '2.2.1'

default['backup']['server']       = {}

override['rvm']['users']['root'] = {
  'rubies' => {
    node['backup']['rvm_ruby'] => {
      'default' => true
    }
  },
 'gems' => {
    node['backup']['rvm_ruby'] => [
      {'gem' => 'backup', 'version' => node['backup']['version'], 'action' => 'install'}
    ]
  },
  'rvmrc' => {
    'rvm_verify_downloads_flag' => 1,
    'rvm_trust_rvmrcs_flag' => 1,
    'rvm_autoupdate_flag' => 1
  }
}