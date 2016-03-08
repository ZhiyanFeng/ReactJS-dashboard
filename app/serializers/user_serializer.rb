class UserSerializer < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  attributes :id,
  :active_org,
  :first_name, 
  :last_name, 
  :email, 
  :gender,
  :chat_handle, 
  :user_group, 
  :position,
  :location,
  :status
  #:profile_image
  
  #def profile_image
    #Image.find(object.profile_id)
    #ProfileImageSerializer.new(object.profile_image)
  #end

   def user_group
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end

  def position
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
