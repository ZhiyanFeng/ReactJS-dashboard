class LocationDashboardSerializer < ActiveModel::Serializer
  attributes :id,
  :member_count,
  :lng,
  :lat,
  :location_name,
  :unit_number,
  :street_number,
  :address,
  :city,
  :province,
  :country,
  :postal,
  :is_hq,
  :four_sq_id,
  :google_map_id

  def four_sq_id
    # check whether the result is null
    if object.four_sq_id.present?
      object.four_sq_id
    else
      ""
    end
  end

  def google_map_id
    # check whether the result is null
    if object.google_map_id.present?
      object.google_map_id
    else
      ""
    end
  end

  def member_count
    User.where(:location => object.id).count
  end

  def unit_number
    if object.unit_number.present?
      object.unit_number
    else
      ""
    end
  end
end
