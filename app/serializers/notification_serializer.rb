class NotificationSerializer < ActiveModel::Serializer
  attributes :id,
  :source, 
  :source_id, 
  :event,
  :viewed,
  :message,
  :created_at,
  :sender,
  :recipient
  
  
  def sender
    OwnerSerializer.new(object.sender)
  end
  
  def recipient
    OwnerSerializer.new(object.recipient)
  end
  
end
