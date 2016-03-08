class KeychainSerializer < ActiveModel::Serializer
  has_many :organizations, embed: :objects
  has_many :user_privileges, embed: :objects
end