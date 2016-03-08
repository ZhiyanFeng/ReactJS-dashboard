class ChatMessageSerializer < ActiveModel::Serializer
  attributes :id,
    :message,
    :sender_id,
    :message_type,
    :attachment,
    :created_at

  #params :outdated
    
  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @attachments.to_objs
    end
  end

  def message
    if object.message.match(/^\[IMG\].+\[\/IMG\]$/)
      #if object.outdated == true
      if serialization_options[:outdated] == true
        "[This user tried to send you an image, you need to update your app to view it.]"
      else
        object.message
      end
    else
      object.message
    end
  end
end
