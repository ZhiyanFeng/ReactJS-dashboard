class ShiftStandaloneSerializerSelfRoot < ActiveModel::Serializer
  self.root = "shift"
  attributes :id,
  :post_id,
  :location,
  :owner_id,
  :poster_name,
  :poster,
  :coverer_name,
  :coverer,
  :coverer_id,
  :trade_status,
  :tip_amount,
  :tipping_user,
  :tipping_user_id,
  :start_at,
  :end_at,
  :created_at,
  :allow_delete,
  :require_approval,
  :can_approve,
  :comments_count

  def allow_delete
    if object.user_id.to_i == object.owner_id.to_i
      return true
    elsif Subscription.exists?(:user_id => object.user_id, :is_admin => true, :channel_id => object.channel_id, :is_valid => true) || UserPrivilege.exists?(:owner_id => object.user_id, :is_admin => true, :location_id => object.location_id, :is_valid => true)
      return true
    else
      return false
    end
  end

  def require_approval
    if Channel.exists?(:id => object.channel_id)
      @channel = Channel.find(object.channel_id)
      if @channel[:shift_trade_require_approval]
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def can_approve
    if Subscription.exists?(:user_id => object.user_id, :is_admin => true, :channel_id => object.channel_id, :is_valid => true) || UserPrivilege.exists?(:owner_id => object.user_id, :is_admin => true, :location_id => object.location_id, :is_valid => true)
      return true
    else
      return false
    end
  end

  def poster_name
    @poster = User.find(owner_id)
    @poster[:first_name] + " " + @poster[:last_name]
  end

  def poster
    @poster = User.find(owner_id)
    UserSimpleSerializer.new(@poster)
  end

  def coverer_name
    if object.coverer_id.present?
      @coverer = User.find(coverer_id)
      @coverer[:first_name] + " " + @coverer[:last_name]
    else
      nil
    end
  end

  def coverer
    if object.coverer_id.present?
      @coverer = User.find(coverer_id)
      UserSimpleSerializer.new(@coverer)
    else
      nil
    end
  end

  def approver_name
    if object.approver_id.present?
      @approver = User.find(approver_id)
      @approver[:first_name] + " " + @approver[:last_name]
    else
      nil
    end
  end

  def tip_amount
    if Gratitude.exists?(:shift_id => object.id)
      Gratitude.where(:shift_id => object.id, :is_valid => true).sum(:amount)
    else
      0
    end
  end

  def tipping_user
    if Gratitude.exists?(:shift_id => object.id, :is_valid => true)
      @tip = Gratitude.where(:shift_id => object.id, :is_valid => true).first
      @user = User.find(@tip[:owner_id])
      @user[:first_name] + " " + @user[:last_name]
    else
      0
    end
  end

  def tipping_user_id
    if Gratitude.exists?(:shift_id => object.id, :is_valid => true)
      @tip = Gratitude.where(:shift_id => object.id, :is_valid => true).first
      @tip[:owner_id]
    else
      0
    end
  end

  def location
    if object.location_id.present?
      if Location.exists?(:id => object.location_id)
        ShiftLocationSerializer.new(object.location)
      else
        nil
      end
    else
      nil
    end
  end

  def comments_count
    @post = Post.find(object.post_id)
    @post[:comments_count]
  end
end