#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2010, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute

gem_package 'whenever'

gem_package 'backup' do
  version '3.0.6'
end

# Application-based backups
search(:apps) do |app|
  models = []
  backup_path = "#{app[:deploy_to]}/shared/backup"

  if app.has_key? :backups
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
