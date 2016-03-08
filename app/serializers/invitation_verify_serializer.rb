class InvitationVerifySerializer < ActiveModel::Serializer
  self.root = false
  
  attributes :id,
  :is_invited,
  :is_whitelisted,
  :org_id,
  :first_name, 
  :last_name, 
  :email,
  :phone_number,
  :user_group, 
  :location,
  :organization

  def organization
    if object.org_id.present?
      @organization = Organization.find(object.org_id)
      OrganizationSerializer.new(@organization)
    else
      nil
    end
  end

end
