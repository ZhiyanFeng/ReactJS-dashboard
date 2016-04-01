class SlackChannelPushReporterWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(report_id)
    begin
      #curl -X POST --data-urlencode 'payload={"channel": "#general", "username": "webhookbot", "text": "This is posted to #general and comes from a bot named webhookbot.", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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
      @cpr = ChannelPushReport.find(report_id)
      c = Curl::Easy.new
      c.url = "https://hooks.slack.com/services/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"
      c.verbose = true
      #payload = "{\"text\":\"Channel Push Event -- [ID : #{@cpr[:id]}] -- [CHANNEL ID : #{@cpr[:channel_id]}] -- [TARGET SIZE : #{@cpr[:target_number]}] -- [ATTEMPTED : #{@cpr[:attempted]}] -- [SUCCESS : #{@cpr[:success]}] -- [FAILED(MISSING PUSH ID) : #{@cpr[:failed_due_to_missing_id]}] -- [FAILED : #{@cpr[:failed_due_to_other]}] -  \",\"icon_emoji\":\":flag-cn:\"}"
      payload = "{\"attachments\":[{\"fallback\":\"Channel Push Event -- [ID : #{@cpr[:id]}] -- [CHANNEL ID : #{@cpr[:channel_id]}] -- [TARGET SIZE : #{@cpr[:target_number]}] -- [ATTEMPTED : #{@cpr[:attempted]}] -- [SUCCESS : #{@cpr[:success]}] -- [FAILED(MISSING PUSH ID) : #{@cpr[:failed_due_to_missing_id]}] -- [FAILED : #{@cpr[:failed_due_to_other]}] -  \",\"text\":\"Channel Push Event Occured #{@cpr[:created_at]}\",\"fields\":[{\"title\":\"ID\",\"value\":\"#{@cpr[:id]}\",\"short\":true},{\"title\":\"Channel ID\",\"value\":\"#{@cpr[:channel_id]}\",\"short\":true},{\"title\":\"Target Size\",\"value\":\"#{@cpr[:target_number]}\",\"short\":true},{\"title\":\"Pushes Attempted\",\"value\":\"#{@cpr[:attempted]}\",\"short\":true},{\"title\":\"Pushes Succeeded\",\"value\":\"#{@cpr[:success]}\",\"short\":true},{\"title\":\"Failed (Missing Push ID)\",\"value\":\"#{@cpr[:failed_due_to_missing_id]}\",\"short\":true},{\"title\":\"Failed (Other)\",\"value\":\"#{@cpr[:failed_due_to_other]}\",\"short\":true}],\"color\":\"#7CD197\"}]}"
      c.http_post(payload)
    rescue Exception => error
      ErrorLog.create(
        :file => "slack_channel_push_reporter_worker.rb",
        :function => "perform",
        :error => "Unable to report to slack: #{error}")
    end
  end
end