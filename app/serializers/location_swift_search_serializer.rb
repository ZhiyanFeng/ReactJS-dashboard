class LocationSwiftSearchSerializer < ActiveModel::Serializer
  attributes :google_map_id,
  :member_count,
  :formatted_address,
  :id,
  :location_name,
  :admin_name,
  :admin_profile

  def admin_name
    if UserPrivilege.exists?(:location_id => object[:id], :is_admin => true, :is_valid => true)
      priv = UserPrivilege.where(["location_id = ? AND is_admin AND is_valid", object[:id]]).first
      user = User.find(priv[:owner_id])
      user[:first_name]
    end
  end

  def admin_profile
    if UserPrivilege.exists?(:location_id => object[:id], :is_admin => true, :is_valid => true)
      priv = UserPrivilege.where(["location_id = ? AND is_admin AND is_valid", object[:id]]).first
      user = User.find(priv[:owner_id])
      user.profile_image.thumb_url
    end
  end
end
