class UserPrivilegeSerializer < ActiveModel::Serializer
	has_one :organization, serializer: OwnerOrganizationSerializer
  attributes :org_id,
  #:organization,
  :is_admin,
  :is_approved,
  :read_only
end


#def organization
#	@org = Organization.find(:org_id)
#	OwnerOrganizationSerializer.new(@org)
#end