# Description

Uses the [Backup Ruby Gem](https://github.com/meskyanichi/backup) to perform backups.

# Requirements

Tested on Ubuntu Linux with Ruby 1.9, but should run on any Unix with Ruby.

# Attributes

See `attributes/default.rb` for default vaules.

* `node['backup']['config_path']` - Where backup configuration data will be stored. Defaults is `/etc/backup`.
* `node['backup']['model_path']` - Where backup models (definitions) are stored. Default is `node['backup']['config_path']/models`
* `node['backup']['user']` - User that performs backups. Default is root.
* `node['backup']['group']` - Group that performs backups. Default is root.
* `node['backup']['version']` - Version of the Backup gem to be installed. The latest version of this cookbook should have the latest stable version of the gem.

# Recipes

The `backup::default` recipe installs the backup gem and its dependencies and sets up the basic configuration.
