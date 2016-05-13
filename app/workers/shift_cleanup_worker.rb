class ShiftCleanupWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform
    @list = ScheduleElement.where(["is_valid AND end_at < now() - interval '14 days'"])
    @list.each do |shift|
      begin
        shift.parent.parent.update_attributes(:is_valid => false, :z_index => 9999)
        shift.update_attribute(:is_valid, false)
      rescue => e
        ErrorLog.create(
          :file => "shift_cleanup_worker.rb on line #{__LINE__}",
          :function => "perform",
          :error => "Error: #{e}")
      end
    end
  end
end
