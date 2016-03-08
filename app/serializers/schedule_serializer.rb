class ScheduleSerializer < ActiveModel::Serializer
  self.root = "schedule"
  attributes :id,
  :org_id,
  :admin_id,
  :shift_trade,
  :start_date,
  :end_date,
  :trade_authorization,
  :snapshot_url,
  :schedules
  
  def schedules
    object.schedule_elements.each
  end
end
