[![Build Status](https://travis-ci.org/cramerdev/backup-cookbook.png)](https://travis-ci.org/cramerdev/backup-cookbook)

# Description

Uses the [Backup Ruby Gem](https://github.com/meskyanichi/backup) to perform backups.

# Requirements

Tested on Ubuntu Linux with Ruby 1.9.3, but should run on any Unix with Ruby.

Ruby 1.8.7 and 1.9.2 are no longer supported.  If you require the support of
older Ruby versions, you should use v1.0.0 of this cookbook.  If you want to use
v4 of the gem, you need to use this version.

# Attributes

See `attributes/default.rb` for default vaules.

* `node['backup']['config_path']` - Where backup configuration data will be stored. Defaults is `/etc/backup`
* `node['backup']['log_path']` - Where backup logs will be stored. Defaults is `/var/log`
* `node['backup']['addl_flags']` - Additional flags to pass on to the backup executable, such as `--tmp-path`
* `node['backup']['model_path']` - Where backup models (definitions) are stored. Default is `node['backup']['config_path']/models`
* `node['backup']['mount_options']` String or Array of [mount options](https://docs.getchef.com/resource_mount.html#attributes). (example: `["rw", "nfsvers=3"]` would become the comma-delimited string, `rw,nfsvers=3`, passed to the `-o` argument of the `mount` command and inserted into the `<options>` column of `/etc/fstab`).
* `node['backup']['dependencies']` - An array of arrays of additional dependencies and optional versions needed for backups. The backup gem will inform you about these when the backup runs. (examples: `['fog']`, `[['fog', '1.4.0'], ['s3']]`)
* `node['backup']['user']` - User that performs backups. Default is root
* `node['backup']['group']` - Group that performs backups. Default is root
* `node['backup']['version']` - Version of the Backup gem to be installed. The latest version of this cookbook should have the latest stable version of the gem
* `node['backup']['server']` - Data about a centralized backup server. Used by the `backup_mount` resource. Default is an empty hash.
* `node['backup']['server']['address']` - Address of the backup server.
* `node['backup']['server']['root_path']` - Root path on the server where backups go.

# Recipes

## default

The default recipe installs the backup gem and its dependencies and sets up the basic configuration.

# Resources and Providers

## backup_model

Creates a backup model with an optional `cron` schedule.

### Actions

* `:create` - Create a model. The default.
* `:delete` - Delete a model

### Attribute Parameters

* The name attribute - A symbol used as the trigger name.
* `description` - A description for the backup. Default is the same as the name.
* `definition` - A string (best formed as a heredoc) defining the backup. Will be interpoleted and turned into a model file. Required.
* `schedule` - A hash of times (minute, hour, day, month, weekday) that will be passed to a [`cron` resource](http://docs.opscode.com/chef/resources.html#cron).
* `cron_options` - A hash of other options to be passed to the `cron` resource. Includes `:command` (will be set to the generated backup command by default), `:mailto`, `:path`, `:shell`, `:user`. Set `output_log` option to redirect output of the generated backup command  to the log file (by default this output will be ignored).

### Example

This will create a model scheduled to back up a database daily:

    backup_model :my_db do
      description "Back up my database"

      definition <<-DEF
        split_into_chunks_of 4000

        database MySQL do |db|
          db.name = 'mydb'
          db.username = 'myuser'
          db.password = '#{node['mydb']['password']}' # will be interpolated
        end

        compress_with Gzip

        store_with S3 do |s3|
          s3.access_key_id = '#{node['aws']['access_key_id']}'
          s3.secret_access_key = '#{node['aws']['secret_access_key']}'
          s3.bucket = 'mybucket'
        end
      DEF

      schedule({
        :minute => 0,
        :hour   => 0
      })
    end

## backup_mount

Defines an NFS mount to be used for backup storage and creates the necessary directories. Uses the `node['backup']['server']` attributes.

This fits a specific use case and may or may not be useful. It is intended to be used with the RSync::Local syncer and Local storage option.

### Actions

* `:enable` - Enables and mounts the device
* `:disable` - Disables and unmounts the device

### Attribute Parameters

* Name attribute: The path where the mount will be placed.
* `remote_path`: The path being accessed on the remote server

### Example

Given the following attributes:

* `node['backup']['server']['address'] = '192.168.0.2'`
* `node['backup']['server']['root_path'] = 'volume1'`

And this in the recipe:

    backup_mount '/mnt/backup/myapp' do
      remote_path '/backups/myapp' # Will be prefixed with with the `node['backup']['server']['root_path']` if it is set.
    end

will create an NFS mount at /mnt/backup/myapp with the device 192.168.0.2:/volume1/backups/myapp.
