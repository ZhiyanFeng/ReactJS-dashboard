class InviteeManagementSerializer < ActiveModel::Serializer
  self.root = false
  #has_one :profile_image, serializer: ProfileImageSerializer
  attributes :id,
  :first_name, 
  :last_name, 
  :email,
  :phone_number,
  :user_group, 
  :position,
  :location,
  :created_at
  
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
