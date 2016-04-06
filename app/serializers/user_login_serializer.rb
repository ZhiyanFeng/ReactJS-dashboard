class UserLoginSerializer < ActiveModel::Serializer
  self.root = false
  has_one :profile_image, serializer: ProfileImageSerializer
  has_one :cover_image, serializer: CoverImageSerializer
  attributes :id,
  :active_org,
  :first_name,
  :last_name,
  :email,
  :phone_number,
  :gender,
  :chat_handle,
  :referral_code,
  :user_group_id,
  :user_group,
  :position,
  :location_id,
  :location,
  :status
  #:profile_image

  #def profile_image
    #Image.find(object.profile_id)
    #ProfileImageSerializer.new(object.profile_image)
  #end

  def referral_code
    object.get_referral_code
  end

  def user_group_id
    object.user_group
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

  def position
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end

  def location_id
    object.location
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
