class ChatSessionSerializer < ActiveModel::Serializer
  has_many :participants
  attributes :id,
  :org_id,
  :message_count,
  :participant_count,
  :chat_title,
  :latest_message,
  :multiuser_chat,
  :updated_at

  def chat_title
    "Chat~~ PEWPEW"
  end
end
