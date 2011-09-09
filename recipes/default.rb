#
# Cookbook Name:: backup
# Recipe:: default
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

gem_package 'whenever'

gem_package 'fog' do
  version '>= 0.11.0'
end

gem_package 'popen4' do
  version '~> 0.1.2'
end

gem_package 'backup' do
  version node['backup']['version']
end

if node['languages']['ruby']['version'][0..2] == '1.8'
  gem_package 's3sync'
else
  gem_package 'aproxacs-s3sync'
end

# Application-based backups
search(:apps) do |app|
  models = []
  backup_path = "#{app[:deploy_to]}/shared/backup"

  if app.has_key? :backups && (node.run_list.roles & app[:server_roles]).length > 0
    app[:backups].each_pair do |id, backup|
      model = backup
      model[:id] = "#{app[:id]}_#{id}"
      model[:app_db] = app[:databases][node[:app_environment]]
      models << model
    end

    template "#{app[:deploy_to]}/shared/config/backup.rb" do
      source 'app_backup.rb.erb'
      owner app[:owner] || 'root'
      group app[:group] || 'root'
      mode 0600
      variables :models => models
    end

    template "#{app[:deploy_to]}/shared/config/schedule.rb" do
      source 'app_schedule.rb.erb'
      owner app[:owner] || 'root'
      group app[:group] || 'root'
      mode 0644
      variables({
        :models => models,
        :args => "--log-path=#{backup_path}/log --tmp-path=#{backup_path}/tmp --config-file=#{app[:deploy_to]}/shared/config/backup.rb --data-path=#{backup_path}/data"
      })
    end

    execute "write crontab for #{app[:id]}" do
      user = app[:owner] || 'root'
      command "whenever --write-crontab #{app[:id]} --set path=$PATH --load-file #{app[:deploy_to]}/shared/config/schedule.rb --user #{user}"
    end
  end
end

# Backups from "backups" data bag
backup_path = node['backup']['path'] || '/var/backups'
user = node['backup']['user'] || 'root'

search(:backups) do |bag|
  if (bag[:nodes] || []).include?(node.name)
    models = []

    if bag.has_key? :backups
      bag[:backups].each_pair do |id, backup|
        model = backup
        model[:id] = "#{bag[:id]}_#{id}"
        model[:app_db] = {} # not used
        models << model
      end

      template "#{backup_path}/backup.rb" do
        source 'app_backup.rb.erb'
        owner user
        group user
        mode 0600
        variables :models => models
      end

      template "#{backup_path}/schedule.rb" do
        source 'app_schedule.rb.erb'
        owner user
        group user
        mode 0644
        variables({
          :models => models,
          :args => "--log-path=#{backup_path}/log --tmp-path=#{backup_path}/tmp --config-file=#{backup_path}/backup.rb --data-path=#{backup_path}/data"
        })
      end

      execute "write crontab for #{bag[:id]}" do
        command "#{node[:languages][:ruby][:bin_dir]}/whenever --write-crontab #{bag[:id]} --set path=$PATH --load-file #{backup_path}/schedule.rb --user #{user}"
      end
    end
  end
end
