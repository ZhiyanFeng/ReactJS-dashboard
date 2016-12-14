class SyncChannelProfileSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id,
  :channel_type,
  :channel_frequency,
  :channel_name,
  :channel_profile_url,
  :channel_latest_content,
  :channel_content_count,
  :owner_id,
  :member_count,
  :is_active,
  :swift_code,
  :become_active_when,
  :allow_view,
  :allow_post,
  :allow_shift_trade,
  :allow_schedule,
  :allow_announcement,
  :allow_comment,
  :allow_like,
  :allow_view_profile,
  :allow_view_covered_shifts,
  :shift_trade_require_approval,
  :updated_at,
  :channel_physical_address,
  :is_valid

  def channel_profile_url
    if object.channel.profile_image.present?
      object.channel.profile_image.thumb_url
    end
  end

  def channel_physical_address
    if object.channel.channel_type.include? "location_feed"
      @location = Location.find(object.channel.channel_frequency.to_i)
      LocationDashboardSerializer.new(@location, scope: scope, root: false)
    elsif object.channel.channel_type.include? "organization_feed"

    end
  end

  def swift_code
    if object.channel.channel_type.include? "location_feed"
      if Location.exists?(:id => object.channel.channel_frequency.to_i)
        location = Location.find(object.channel.channel_frequency.to_i)
        location[:swift_code]
      else
      end
    else
    end
  end

  def id
    object.channel.id
  end

  def channel_type
    object.channel.channel_type
  end

  def channel_frequency
    object.channel.channel_frequency
  end

  def channel_name
    object.channel.channel_name
  end

  def channel_profile_id
    object.channel.channel_profile_id
  end

  def channel_latest_content
    object.channel.channel_latest_content
  end

  def channel_content_count
    object.channel.channel_content_count
  end

  def owner_id
    object.channel.owner_id
  end

  def member_count
    object.channel.member_count
  end

  def is_active
    object.channel.is_active
  end

  def become_active_when
    if object.channel.become_active_when.present?
      str_arry = object.channel.become_active_when.split
      if str_arry[0] == "member_count"
       # "Invite #{str_arry[2]} members to unlock this channel.&&&#{object.channel.member_count}&&&#{str_arry[2]}"
       "Activates when reaches #{str_arry[2]} members.&&&#{object.channel.member_count}&&&#{str_arry[2]}"
      elsif str_arry[0] == "date"
        "This channel will be unlocked on Jan 1st, 2020.&&&1631 more days"
      else
        "This channel will be unlock when Daniel says so."
      end
    else
      nil
    end
  end

  def allow_view
    object.channel.allow_view
  end

  def allow_post
    @sub = Subscription.find(object.id)
    if @sub[:allow_post] > 0
      true
    elsif @sub[:allow_post] < 0
      false
    else
      object.channel.allow_post
    end
  end

  def allow_shift_trade
    object.channel.allow_shift_trade
  end

  def allow_schedule
    object.channel.allow_schedule
  end

  def allow_announcement
    @sub = Subscription.find(object.id)
    if @sub[:allow_post] > 0
      true
    elsif @sub[:allow_post] < 0
      false
    else
      object.channel.allow_announcement
    end
  end

  def allow_comment
    object.channel.allow_comment
  end

  def allow_like
    object.channel.allow_like
  end

  def allow_view_profile
    object.channel.allow_view_profile
  end

  def allow_view_covered_shifts
    object.channel.allow_view_covered_shifts
  end

  def shift_trade_require_approval
    object.channel.shift_trade_require_approval
  end

  def updated_at
    object.channel.updated_at
  end

end
