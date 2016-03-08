class DashboardPollResultSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id,
  :question_count,
  :score,
  :answer_key,
  :answer_json,
  :passed,
  :user_id,
  :created_at

  def answer_json
  	if object.answer_json.present?
  		object.answer_json.html_safe
  	else
  		nil
  	end
  end
end
