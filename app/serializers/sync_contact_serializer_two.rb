class SyncContactSerializerTwo < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  has_one :cover_image, serializer: ProfileImageSerializer
  attributes :id,
  :first_name, 
  :last_name, 
  :chat_handle, 
  :location_name,
  :location_address,
  :status,
  :created_at,
  :updated_at

  def location_name
    if object.location.present?
      if Location.where(:id => object.location).exists?
        @location = Location.find(object.location)
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
    if object.location.present?
      if Location.where(:id => object.location).exists?
        @location = Location.find(object.location)
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
