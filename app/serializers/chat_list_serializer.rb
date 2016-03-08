class ChatListSerializer < ActiveModel::Serializer
  has_many :participants
  attributes :id,
  :org_id,
  :message_count,
  :participant_count,
  :latest_message,
  :created_at
end
