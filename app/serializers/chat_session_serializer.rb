class ChatSessionSerializer < ActiveModel::Serializer
  has_many :participants
  attributes :id,
  :org_id,
  :message_count,
  :participant_count,
  :latest_message,
  :multiuser_chat,
  :updated_at
end
