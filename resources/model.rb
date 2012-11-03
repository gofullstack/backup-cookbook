actions :create, :delete

attribute :name, :kind_of => Symbol, :name_attribute => true, :required => true
attribute :description, :kind_of => String
attribute :definition, :kind_of => String, :required => true
attribute :schedule, :kind_of => Hash

# Set default
def initialize(*args)
  super
  @action = :create
end
