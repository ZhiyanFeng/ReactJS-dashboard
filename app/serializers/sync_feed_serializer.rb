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

  def sorted_at
    if object.attachment_id.present? && object.title == "Shift Trade"
      if
        @attachment = Attachment.where(["id = #{object.attachment_id} AND json like '{\"objects\":[{\"source\":11,\"source_id\":%%'"])
        objArray = JSON.parse(self.json)
        objArray["objects"].each do |p|
          if ScheduleElement.exists?(:id => p["source_id"])
            obj = ScheduleElement.find(p["source_id"])
            if Gratitude.exists?(:shift_id => obj[:id], :is_valid => true) && obj[:end_at].to_time < Time.now
              Time.now
            else
              object.sorted_at
            end
          else
            object.sorted_at
          end
        end
      else
        object.sorted_at
      end
    else
      object.sorted_at
    end
  end
end
