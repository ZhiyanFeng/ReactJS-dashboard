class SyncContactThruPrivilegeSerializer < ActiveModel::Serializer
  #has_one :profile_image, serializer: ProfileImageSerializer
  #has_one :cover_image, serializer: ProfileImageSerializer
  attributes :id,
  :first_name, 
  :last_name, 
  :chat_handle, 
  :location_name,
  :location_address,
  :status,
  :profile_image,
  :cover_image,
  :created_at,
  :updated_at,
  :is_valid

  def id
    object.user.id
  end

  def first_name
    object.user.first_name
  end

  def last_name
    object.user.last_name
  end

  def chat_handle
    object.user.chat_handle
  end

  def status
    object.user.status
  end

  def profile_image
    ProfileImageSerializer.new(object.user.profile_image)
  end

  def cover_image
    ProfileImageSerializer.new(object.user.cover_image)
  end


  #CHANGE THIS
  def created_at
    object.updated_at
  end

  def location_name
    if object.location_id.present?
      if Location.where(:id => object.location_id).exists?
        @location = Location.find(object.location_id)
        if @location[:location_name].present?
          @location[:location_name]
        else
          ""
        end
      else
        "Friend"
      end
    end
  end

  def location_address
    if object.location_id.present?
      if Location.where(:id => object.location_id).exists?
        @location = Location.find(object.location_id)
        if @location[:address].present?
          @location[:address]
        else
        end
      else
        ""
      end
    end
  end
end
