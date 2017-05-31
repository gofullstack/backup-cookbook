#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2011-2012, Cramer Development, Inc.
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

if node['backup']['install_gem?']
  if node['backup']['version_from_git?']
    include_recipe 'gem_specific_install'
    gem_specific_install 'backup' do
      repository node['backup']['git_repo']
      revision 'master'
      action :install
    end
  else
    gem_package 'backup' do
      version node['backup']['version'] if node['backup']['version']
      action :upgrade if node['backup']['upgrade?']
    end
  end
end

node['backup']['dependencies'].each do |gem, ver|
  gem_package gem do
    version ver if ver
  end
end

%w[ config_path model_path ].each do |dir|
  directory node['backup'][dir] do
    owner node['backup']['user']
    group node['backup']['group']
    mode '0700'
  end
end

template 'Backup config file' do
  path ::File.join( node['backup']['config_path'], 'config.rb')
  source 'config.rb.erb'
  owner node['backup']['user']
  group node['backup']['group']
  mode '0600'
end
