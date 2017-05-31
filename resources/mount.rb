actions :enable, :disable
default_action :enable

attribute :path, :kind_of => String, :name_attribute => true, :required => true
attribute :remote_path, :kind_of => String, :default => ''
