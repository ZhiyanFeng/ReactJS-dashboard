class OrganizationSerializer < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  attributes :id, 
  :name, 
  :address, 
  :city,
  :country,
  # DAVID ADDED
  :secure_network,
  :profanity_filter,
  # END DAVID ADDED
  :formatted_address

  def formatted_address
	  address_line = ""
	  locale_line = ""

    address_line = address_line + object.unit_number + " - " if object.unit_number.present?
    address_line = address_line + object.street_number + " " if object.street_number.present?
    address_line = address_line + object.address if object.address.present?

    locale_line = locale_line + object.city + " - " if object.city.present?
    locale_line = locale_line + object.province + " - " if object.province.present?
    locale_line = locale_line + object.country if object.country.present?
  	
  	"<address>" + address_line + "<br />" + locale_line + "</address>"
  end
end
