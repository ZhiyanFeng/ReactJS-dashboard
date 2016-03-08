class PostTypeSerializer < ActiveModel::Serializer
  attributes :description, 
  :image_count,
  :includes_video,
  :includes_url54,
  :includes_audio,
  :includes_event,
  :includes_survey,
  :includes_shift,
  :includes_schedule,
  :includes_layover,
  :includes_safety_course,
  :allow_comments,
  :allow_likes,
  :allow_flags,
  :allow_delete
end
