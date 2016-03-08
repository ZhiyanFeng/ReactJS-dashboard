class MessionSerializer < ActiveModel::Serializer
  has_one :user
  attributes :id
end
