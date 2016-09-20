class ChannelProfileSerializerV2 < ActiveModel::Serializer
  self.root = false
  attributes :id,
  :channel_name,
  :member_count,
  :description,
  :channel_profile

  def channel_profile
    if object.profile_image.present?
      object.profile_image.thumb_url
    end
  end
end
