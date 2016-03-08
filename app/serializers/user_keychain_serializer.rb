class UserKeychainSerializer < ActiveModel::Serializer
  has_many :keys
  attributes :first_name, 
  :last_name, 
  :chat_handle, 
  :user_group, 
  :location,
  :position

  def user_group
    if object.user_group.present?
      if UserGroup.exists?(object.user_group)
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end

  def position
    if object.user_group.present?
      if UserGroup.exists?(object.user_group)
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team Member"
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
