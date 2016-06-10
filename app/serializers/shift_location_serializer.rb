class ShiftLocationSerializer < ActiveModel::Serializer
  self.root = false
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
    if object.address.present?
      line = object.address
    else
      if object.unit_number.present?
        line = line + object.unit_number + "-"
      end
      if object.street_number.present?
        line = line + object.street_number + " " + object.address
      end
    end
  end

  def location_city
    line = ""
    if object.city.present?
      line = object.city
    end
    if object.province.present?
      line = line + ", " + object.province
    end
    if object.postal.present?
      line = line + ", " + object.postal
    end
    line
  end
end