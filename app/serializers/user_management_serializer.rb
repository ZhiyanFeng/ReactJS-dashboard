class UserManagementSerializer < ActiveModel::Serializer
  self.root = false
  #has_one :profile_image, serializer: ProfileImageSerializer
  attributes :id,
  :first_name, 
  :last_name, 
  :email,
  :number,
  :user_group,
  :position,
  :location,
  :status,
  :is_admin,
  :profile_image,
  :user_group_name,
  :location_name
  
  def user_group_name

    # if the user group is not empty
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        nil
      end
    else
      nil
    end
  end

  def location_name

    # if the location is not empty
    if object.location.present?
      if Location.where(:id => object.location).exists?
        Location.find_by_id(object.location).location_name
      else
        nil
      end
    else
      nil
    end
  end

  def is_admin
    if object.class.name == "User"
      if object.user_privileges.first.present?
        if object.user_privileges.first.is_admin
          1
        else
          0
        end
      end
    else
      0
    end
  end

  def profile_image
    begin
      @image = Image.find(object.profile_id)
      ProfileImageSerializer.new(@image)
    rescue

    end
  end

  def status
    if object.class.name == "User"
      if object.is_valid
        1
      else
        -1
      end
    else
      0
    end
  end

  def number
    if object.class.name == "User"
      if object.phone_number.present?
        object.phone_number
      else
        nil
      end
    else
      nil
    end
  end

  #def user_group
  #  if object.user_group.present?
  #    if UserGroup.where(:id => object.user_group).exists?
  #      UserGroup.find_by_id(object.user_group).group_name
  #    else
  #      nil
  #    end
  #  end
  #end

  def position
    #if object.user_group.present?
    #  if UserGroup.where(:id => object.user_group).exists?
    #    UserGroup.find_by_id(object.user_group).group_name
    #  else
    #    nil
    #  end
    #end
    object.user_group
  end

  #def location
  #  if object.user_group.present?
  #    if Location.where(:id => object.location).exists?
  #      Location.find_by_id(object.location).location_name
  #    else
  #      nil
  #    end
  #  end
  #end
end
