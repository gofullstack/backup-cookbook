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

gem_package "whenever"

# activemodel requires builder (~> 2.1.2, runtime) (Gem::InstallError)
gem_package "builder" do
  version "~> 2.1.2"
end

gem_package "backup" do
  notifies :run, resources(:execute => "backup --setup")
end
