#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2010, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute

gem_package 'whenever'

gem_package 'backup' do
  version '3.0.14'
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
backup_path = (node[:backup] || {})[:path] || '/var/backups'
user = (node[:backup] || {})[:user] || 'root'

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
        command "whenever --write-crontab #{bag[:id]} --set path=$PATH --load-file #{backup_path}/schedule.rb --user #{user}"
      end
    end
  end
end
