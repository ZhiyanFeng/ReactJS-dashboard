class NotificationUserSerializer < ActiveModel::Serializer
  has_one :profile_image
  attributes :id, 
  :first_name, 
  :last_name,
  :gender
end
