class ChannelProfileSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id,
  :channel_name,
  :channel_physical_address,
  :channel_profile_id,
#  :channel_profile,
  :trainings_count,
  :quizzes_count,
  :safety_trainings_count,
  :safety_quiz_count

  def channel_physical_address
    if object.channel_type.include? "location_feed"
      @location = Location.find(object.channel_frequency.to_i)
      ChannelProfileLocationSerializer.new(@location, scope: scope, root: false)
    elsif object.channel_type.include? "organization_feed"
      @organization = Organization.find(object.channel_frequency.to_i)
      ChannelProfileOrganizationSerializer.new(@organization, scope: scope, root: false)
    end
  end

  def trainings_count
    Post.where("post_type IN (11,12,13,18) AND channel_id = #{object.id} AND is_valid").count
  end
  
  def quizzes_count
    Post.where("post_type IN (14,15) AND channel_id = #{object.id} AND is_valid").count
  end
  
  def safety_trainings_count
    Post.where("post_type IN (16) AND channel_id = #{object.id} AND is_valid").count
  end
  
  def safety_quiz_count
    Post.where("post_type IN (17) AND channel_id = #{object.id} AND is_valid").count
  end
end