class PollPostSerializer < ActiveModel::Serializer
  self.root = "poll"
  attributes :id,
  :org_id,
  :attempts,
  :attempts_count,
  :complete_count,
  :question_count,
  :average_score,
  :pass_mark,
  :count_down,
  :start_at,
  :end_at

  def attempts
    @attempts = PollResult.where(:poll_id => object.id)
    object.attempts_count = @attempts.size
    @attempts.map do |attempt|
      PollResultSerializer.new(attempt, scope: scope, root: false)
    end
  end

  #def attempts_count
  #  PollResult.where(:poll_id => object.id).count
  #end

  def complete_count
    PollResult.where("poll_id = '#{object.id}' AND passed").count
  end

  def average_score
    PollResult.find_by_sql("SELECT ROUND(AVG(score),1) FROM poll_results WHERE poll_id = '#{object.id}'")
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
