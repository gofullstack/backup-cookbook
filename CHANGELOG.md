# Backup Cookbook Changelog

## v1.3.0: 2014-12-02

* Add support for passing mount options to the Mount resource.

## v1.2.0: 2014-10-23

* Add addl_flags attribute

## v1.1.2: 2014-10-20

* Fix for device_name in mount provider

## v1.1.1: 2014-08-28

* Add support for cron home option

## v1.1.0: 2014-08-11

* Allow installation of backup gem from a git repository

## v1.0.0: 2014-06-28

* Upgrade to v4.0.1 of backup gem

## v0.4.0: 2014-02-17

* Make Travis builds work
* Do not create cron job in model provider if no schedule is given
* Redirect output of the generated command to the log file if it is specified in `cron\_options`

## v0.3.2: 2014-01-02

* Allow for model names with dashes
* Fix path in model provider's delete action

## v0.3.1: 2013-09-25

* Fix typo in README
* Fix some bugs in templating

## v0.3.0: 2013-07-31

* Add changelog
* Travis CI support
* Foodcrititc and basic testing support
* Attribute to optionally upgrade backup gem
* Use a template for backup model output
* Various other cleanup items

## v0.2.0: 2013-04-10

* Add cron_options
* Pipe cron output to /dev/null

## v0.1.0: 2013-03-27

* Initial release
