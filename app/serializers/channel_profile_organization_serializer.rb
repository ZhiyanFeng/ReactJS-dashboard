class ChannelProfileOrganizationSerializer < ActiveModel::Serializer
  attributes :id,
  :location_name,
  :unit_number,
  :street_number,
  :address,
  :city,
  :province,
  :country,
  :postal

  def location_name
    object.name
  end

  def unit_number
    if object.unit_number.present?
      object.unit_number
    else
      ""
    end
  end
end
