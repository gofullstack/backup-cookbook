#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2010, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute

include_recipe "xml::default" # for nokogiri

execute "backup --setup" do
  creates "/opt/backup"
  action :nothing
end

gem_package "whenever"

# activemodel requires builder (~> 2.1.2, runtime) (Gem::InstallError)
gem_package "builder" do
  version "2.1.2"
end

gem_package "backup" do
  notifies :run, resources(:execute => "backup --setup")
end

backups = {}

search(:apps) do |app|
  (app[:backups] || []).each do |env, app_backups|
    backups.merge!(app_backups) if env == node[:app_environment]
  end
end

p backups

template "/opt/backup/config/backup.rb" do
  source "backup.rb.erb"
  mode 0644
  owner 'root'
  group 'root'
  variables :backups => backups
end
