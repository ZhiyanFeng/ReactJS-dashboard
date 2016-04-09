class ChatSessionSerializer < ActiveModel::Serializer
  has_many :participants
  attributes :id,
  :org_id,
  :message_count,
  :participant_count,
  :title,
  :latest_message,
  :multiuser_chat,
  :updated_at

  def title
    "Chat~~ PEWPEW"
  end
end
