class NotificationCounterSerializer < ActiveModel::Serializer
  attributes :newsfeeds,
  :announcements,
  :trainings,
  :quizzes,
  :contacts,
  :safety_trainings,
  :safety_quiz
end
