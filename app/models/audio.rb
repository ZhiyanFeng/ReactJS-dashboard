class Audio < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  
  attr_accessible :org_id, :owner_id, :audio_type, 
  :audio_file_name, :audio_content_type,:audio_file_size, :is_valid

  has_attached_file :audio, 
  :url => "audios/:id.:basename.:extension",
  :path => "audios/:id.:basename.:extension",
  :storage => :s3
  validates_attachment_presence :audio


  def url
    audio.url
  end
end
