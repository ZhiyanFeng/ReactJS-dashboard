class Keychain
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport
  
  attr_accessor :organizations, :user_privileges

  def initialize(organizations, user_privileges)
    @organizations, @user_privileges = organizations, user_privileges
  end
end