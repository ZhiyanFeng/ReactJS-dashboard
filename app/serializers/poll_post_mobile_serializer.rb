class PollPostMobileSerializer < ActiveModel::Serializer
  self.root = "poll"
  attributes :id,
  :org_id,
  :question_count,
  :pass_mark,
  :count_down,
  :completed,
  :start_at,
  :end_at

  def completed
    if PollResult.exists?(:user_id =>  object.user_id, :poll_id => object.id)
      result = PollResult.where(:user_id =>  object.user_id, :poll_id => object.id).order("score DESC").first
      PollResultSerializer.new(result)
    else
      false
    end
  end

  def start_at
    if object.start_at.present?
      object.start_at.to_json.gsub("\"" , "")
    else
      object.created_at.to_json.gsub("\"" , "")
    end
  end

  def end_at
    object.end_at.to_json.gsub("\"" , "")
  end

end
