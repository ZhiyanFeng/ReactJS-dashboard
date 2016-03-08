# == Schema Information
#
# Table name: post_types
#
#  id               :integer          not null, primary key
#  base_type        :string(255)
#  description      :string(255)
#  image_count      :integer
#  includes_video   :boolean
#  includes_event   :boolean
#  includes_survey  :boolean
#  includes_shift   :boolean
#  includes_layover :string(255)
#  allow_comments   :boolean
#  allow_likes      :boolean
#  allow_flags      :boolean
#  allow_delete     :boolean
#  is_valid         :boolean          default(TRUE)
#  created_at       :timestamp
#  updated_at       :timestamp
#

class PostType < ActiveRecord::Base
  attr_accessible :base_type,
  :description,
  :image_count,
  :includes_video,
  :includes_audio,
  :includes_event,
  :includes_survey,
  :includes_shift,
  :includes_schedule,
  :includes_layover,
  :includes_url,
  :includes_safety_course,
  :includes_pdf,
  :allow_comments,
  :allow_likes,
  :allow_flags,
  :allow_delete

  validates_presence_of :base_type, :on => :create
  validates_presence_of :description, :on => :create
  validates_uniqueness_of :description
  
  def self.get_base_type(name)
    @post_type = PostType.find_by_base_type(name)
    return @post_type[:id]
  end

  def self.reference_by_description(name)
    @posttype = PostType.find_by_description(name)
    return @posttype[:id]
  end
  
  def self.reference_by_type(name)
    @posttype = PostType.find_by_base_type(name)
    return @posttype[:id]
  end
  
  def self.find_post_type(type_id)
    @posttype = PostType.find(type_id)
    return @posttype[:base_type]
  end
  
  def self.reference_by_base_type(base_type)
    @ids = PostType.select(:id).where(:base_type => base_type)
    return @ids
  end
  
  def self.includes_image(id)
    @posttype = PostType.find(id)
    return @posttype[:image_count] > 0 
  end
  
  def self.includes_video(id)
    @posttype = PostType.find(id)
    return @posttype[:includes_video]
  end
  
  def self.includes_audio(id)
    @posttype = PostType.find(id)
    return @posttype[:includes_audio]
  end
  
  def self.includes_event(id)
    @posttype = PostType.find(id)
    return @posttype[:includes_event]
  end
  
  def self.includes_poll(id)
    @posttype = PostType.find(id)
    return @posttype[:includes_survey]
  end
  
  def self.includes_schedule(id)
    @posttype = PostType.find(id)
    return @posttype[:includes_schedule]
  end
  
  def self.includes_shift(id)
    @posttype = PostType.find(id)
    return @posttype[:includes_shift]
  end
end
