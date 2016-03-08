class Announcement < ActiveRecord::Base
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport
  
  attr_accessor :organizations, :posts

  def initialize(organizations, user_privileges)
    @organizations, @user_privileges = organizations, user_privileges
  end
end