class ShiftSerializer < ActiveModel::Serializer
	self.root = "shift"
  attributes :id,
  :owner_id,
  :poster_name,
  :poster,
  :coverer_name,
  :coverer,
  :coverer_id,
  :trade_status,
  :tip_amount,
  :start_at,
  :end_at

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
    50
    #if Gratitude.exists?(:shift_id => object.id)

    #end
  end
end
