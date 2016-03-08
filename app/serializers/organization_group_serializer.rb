class OrganizationGroupSerializer < ActiveModel::Serializer
  attributes :user_groups, :locations

  def user_groups
  	if object.user_groups.present?
	    #ActiveModel::ArraySerializer.new(object.user_groups, each_serializer: UserGroupSerializer)
	    object.user_groups.map do |group|
	      UserGroupSerializer.new(group, scope: scope, root: false)
	    end
		else
			groups ||= Array.new
			group = UserGroup.new(
				:member_count => 0,
				:group_name => "Team member",
				:group_description => "Member of the organization",
				:group_avatar_id => nil
			)
			groups.push(group)
			#ActiveModel::ArraySerializer.new(groups, each_serializer: UserGroupSerializer)
			groups.map do |group|
	      UserGroupSerializer.new(group, scope: scope, root: false)
	    end
		end
  end

  def locations
    #ActiveModel::ArraySerializer.new(object.locations, each_serializer: LocationSerializer)
    object.locations.map do |location|
      LocationSerializer.new(location, scope: scope, root: false)
    end
  end
end
