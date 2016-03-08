class ReportPageQuizzesSerializer < ActiveModel::Serializer  
  attributes :id,
  :org_id,
  :title,
  :content,
  :user_group,
  :location,
  :created_at,
  :attachment,
  :settings,
  :distribution,
  :distribution_count,
  :audience,
  :created_at

  @result = nil

  def location_id
    object.location
  end
  
  def attachment
    if object.attachment_id.presence
      @attachments = Attachment.find(object.attachment_id)
      @result = @attachments.to_objs
    end
  end
  
  def settings
    PostSettingsSerializer.new(object.settings)
  end

  def distribution
    PollResult.where(:poll_id => @result[0].id).maximum(:score, :group => :user_id)
  end

  def distribution_count
    if result = PollResult.where(:poll_id => @result[0].id, :passed => true).maximum(:score, :group => :user_id)
      result.size
    end
  end

  def audience
    if object.user_group > 0 && object.location > 0
      User.where(:active_org => object.org_id, :user_group => object.user_group, :location => object.location).count
    elsif object.user_group == 0 && object.location > 0
      User.where(:active_org => object.org_id, :location => object.location).count
    elsif object.user_group > 0 && object.location == 0
      User.where(:active_org => object.org_id, :user_group => object.user_group).count
    else
      User.where(:active_org => object.org_id).count
    end
  end
end
