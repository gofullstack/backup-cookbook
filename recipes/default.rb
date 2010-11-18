#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2010, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute

execute "backup --setup" do
  creates "/opt/backup"
  action :nothing
end

gem_package "whenever" do
  action :install
end

gem_package "backup" do
  action :install
  notifies :run, resources(:execute => "backup --setup")
end
