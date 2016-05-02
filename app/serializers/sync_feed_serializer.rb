class SyncFeedSerializer < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :type,
  :owner_id,
  :channel_id,
  :title,
  :content,
  :comments_count,
  :likes_count,
  :views_count,
  :liked,
  :flagged,
  :allow_comment,
  :allow_like,
  :created_at,
  :updated_at,
  :sorted_at,
  :attachment_id,
  :attachment,
  :owner,
  :is_valid

  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @attachments.to_objs
    end
  end

  def type
    PostType.find_post_type(object.post_type)
  end

  def liked
    result = false
    if object.likes.presence
      object.likes.each do |l|
        if l.owner_id.to_s == object.user_id.to_s
          result = true
          result
        end
      end
    end
    result
  end

  def flagged
    result = false
    if object.flags.presence
      object.flags.each do |l|
        if l.owner_id.to_s == object.user_id.to_s
          result = true
          result
        end
      end
    end
    result
  end

  def owner
    OwnerSerializer.new(object.owner)
  end

end
