name             'backup'
maintainer       'CA'
maintainer_email 'operations-rally@ca.com'
license          'MIT'
description      'Installs/Configures backup'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue '1.4.0'

depends          'cron'
depends          'gem_specific_install'
depends          'rvm-rally'
