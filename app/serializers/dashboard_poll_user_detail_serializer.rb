class DashboardPollUserDetailSerializer < ActiveModel::Serializer
  attributes :id,
  :org_id,
  :questions,
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
    @attempts = PollResult.where(:poll_id => object.id, :org_id => object.org_id)
    object.attempts_count = @attempts.size
    @attempts.map do |attempt|
      DashboardPollResultSerializer.new(attempt, scope: scope, root: false)
    end
  end

  def questions    
    if object.poll_questions.presence
      #ActiveModel::ArraySerializer.new(object.poll_questions, each_serializer: PollQuestionSerializer)
      object.poll_questions.map do |question|
        DashboardPollQuestionSerializer.new(question, scope: scope, root: false)
      end
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
