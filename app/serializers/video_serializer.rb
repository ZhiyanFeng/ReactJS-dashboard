class VideoSerializer < ActiveModel::Serializer
  self.root = "video"
  attributes :id,
  :video_url,
  :video_id,
  :video_url,
  :video_host,
  :thumb_url,
  :duration_in_ms,
  :video_file_name,
  :video_file_size,
  :video_id,
  :video_duration,
  :encoded_state

  def video_url
  	if object.video_id.present?
	  	object.video_url
  	else
  		object.output_url
  	end

  end
end
