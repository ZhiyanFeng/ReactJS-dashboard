class SchedulePostSignupWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id)
  	PostSignupWorker.perform_async(user_id)
  end
end