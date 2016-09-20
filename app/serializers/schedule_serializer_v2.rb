class ScheduleSerializerV2 < ActiveModel::Serializer
  self.root = "schedule"
  attributes :id,
  :org_id,
  :admin_id,
  :shift_trade,
  :start_date,
  :end_date,
  :trade_authorization,
  :snapshot_url,
  :channel_name,
  :schedules

  def schedules
    object.schedule_elements.each
  end

  def channel_name
    if Channel.exists?(:id => object.channel_id)
      @channel = Channel.find(object.channel_id)
      return @channel[:channel_name]
    end
  end
end
