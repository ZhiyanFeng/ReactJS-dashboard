class ChannelProfileLocationSerializer < ActiveModel::Serializer
  attributes :id,
  :location_name,
  :unit_number,
  :street_number,
  :address,
  :city,
  :province,
  :country,
  :postal

  def unit_number
    if object.unit_number.present?
      object.unit_number
    else
      ""
    end
  end
end
