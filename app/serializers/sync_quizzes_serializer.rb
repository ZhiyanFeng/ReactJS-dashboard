class SyncQuizzesSerializer < ActiveModel::Serializer
  @@poll_id
  
  attributes :id,
  :org_id,
  :owner_id,
  :title,
  :channel_id,
  :content,
  :comments_count,
  :likes_count,
  :views_count,
  :liked,
  :flagged,
  :created_at,
  :updated_at,
  :attachment,
  :completed,
  :is_valid
  
  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @@poll_id = @attachments.to_objs_mobile(object.user_id)
    end
  end
  
  def completed
    if PollResult.exists?(:user_id =>  object.user_id, :poll_id => @@poll_id.first.id)
      result = PollResult.where(:user_id =>  object.user_id, :poll_id => @@poll_id.first.id).order("score DESC").first
      PollResultSerializer.new(result)
    else
      false
    end
  
  end
  
  def owner
    OwnerSerializer.new(object.owner)
  end

  def liked
    false
  end


  def flagged
    false
  end
end
