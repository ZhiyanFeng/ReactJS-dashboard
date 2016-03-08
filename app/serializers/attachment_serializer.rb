class AttachmentSerializer < ActiveModel::Serializer
  has_one :image, embed: :objects
  has_one :video, embed: :objects
  has_one :event, embed: :objects
  has_one :poll, embed: :objects
  has_one :schedule, embed: :objects
  has_one :safety_course, embed: :objects
end
