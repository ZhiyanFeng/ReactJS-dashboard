class ChatParticipantSerializer < ActiveModel::Serializer
  has_one :owner
  attributes :id,
  :session_id,
  :unread_count
end
