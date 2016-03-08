class UserGallerySerializer < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  has_many :gallery_image, serializer: GalleryImageSerializer
  has_one :cover_image, serializer: CoverImageSerializer
  attributes :id, 
  :active_org, 
  :first_name, 
  :last_name, 
  :email, 
  :chat_handle, 
  :user_group, 
  :position,
  :location, 
  :status,
  :gender


  def position
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end
  
  def user_group
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end

  def location
    if object.user_group.present?
      if Location.where(:id => object.location).exists?
        @location = Location.find_by_id(object.location)
        if @location.street_number.present?
          @location.street_number + " " + @location.address
        else
          @location.address
        end
      else
        "Not assigned"
      end
    end
  end
end
