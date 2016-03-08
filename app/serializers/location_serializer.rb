class LocationSerializer < ActiveModel::Serializer
  attributes :id,
  :location_address,
  :location_city,
  :location_name,
  :member_count

  def member_count
    User.where(:location => object.id).count
  end

  def location_address
	line = ""
    if object.unit_number.present?
      line = line + object.unit_number + "-"
    end
    if object.street_number.present?
      line = line + object.street_number + " " + object.address
    end
  end

  def location_city
    if object.province.present?
    	line = object.city + ", " + object.province + ", " + object.postal
    else
      line = object.city + ", " + object.country
    end
  end
end
