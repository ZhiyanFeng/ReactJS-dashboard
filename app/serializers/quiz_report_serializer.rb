class QuizReportSerializer < ActiveModel::Serializer
  attributes :id,
  :poll_id,
  :user_id,
  :question_count,
  :score,
  :answer_key,
  :created_at,
  :updated_at
end
