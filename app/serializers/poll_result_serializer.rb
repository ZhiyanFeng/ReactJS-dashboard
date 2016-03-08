class PollResultSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id,
  :poll_id,
  :user_id,
  :question_count,
  :score,
  :answer_key,
  :passed,
  :created_at,
  :updated_at,
  :answer_json
end
