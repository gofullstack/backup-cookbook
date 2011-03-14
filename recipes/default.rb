#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2010, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute

gem_package "whenever"

gem_package "backup" do
  version '3.0.6'
end
