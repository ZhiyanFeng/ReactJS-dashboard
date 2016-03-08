# == Schema Information
#
# Table name: image_types
#
#  id             :integer          not null, primary key
#  base_type      :string(255)
#  description    :string(255)
#  allow_comments :boolean
#  allow_likes    :boolean
#  allow_flags    :boolean
#  allow_delete   :boolean
#  allow_enlarge  :boolean
#  is_valid       :boolean          default(TRUE)
#  created_at     :timestamp
#  updated_at     :timestamp
#

class ImageType < ActiveRecord::Base
  #belongs_to :images
  
  attr_accessible :base_type,
    :description, 
    :allow_comments, 
    :allow_likes, 
    :allow_flags, 
    :allow_delete, 
    :allow_enlarge
  
  validates_presence_of :base_type, :on => :create
  validates_presence_of :description, :on => :create
  validates_uniqueness_of :description
  
  def self.reference_by_description(name)
    @imagetype = ImageType.find_by_description(name)
    return @imagetype.id
  end
  
  def self.reference_by_type(name)
    @imagetype = ImageType.find_by_base_type(name)
    return @imagetype.id
  end
end
