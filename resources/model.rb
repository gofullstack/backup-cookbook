actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :description, :kind_of => String

attribute :definition, :kind_of => String
attribute :template, :kind_of => Hash
attribute :cookbook, :kind_of => String, :default => 'backup'

attribute :cron_options, :kind_of => Hash
attribute :schedule, :kind_of => Hash


